# GeoServer Workspace JSON Manifests

This repository exports a GeoServer workspace into a portable JSON manifest and
can later create a workspace from that manifest. Exporting only reads the
source GeoServer.

## Scripts

### 1. `export_source_config.py`
Reads a source workspace and writes its stores, feature types, layers, layer
style associations, and complete SLD/CSS style bodies to JSON. It asks for the
target workspace name and a database connection for each store.

### 2. `create_workspace_from_manifest.py`
Creates a workspace from a JSON manifest. It does not connect to or copy from
the original source GeoServer.

The older clone scripts are retained for legacy direct-clone workflows.

> **Note:** These scripts are currently intended for local Python installations on Windows. They have not yet been tested in a server environment.

---

## Prerequisites

Install the following on the machine that runs the scripts:

1. Python 3.10 or newer.
2. The Python package listed in `requirements.txt`:

   ```bash
   python -m pip install -r requirements.txt
   ```

The scripts use only the Python standard library plus `requests`. No Python
PostgreSQL driver, GeoServer SDK, Java installation, Apache, PHP, or browser
is required on the script server.

The following services and access are required:

1. The source GeoServer must be reachable when exporting.
2. The destination GeoServer must be reachable when importing.
3. The GeoServer REST endpoint must be enabled, usually under
   `https://host/geoserver/rest` or `http://host/geoserver/rest`.
4. The GeoServer account must have sufficient permissions to read, or to
   create when importing:
   - Workspaces
   - Data stores
   - Feature types/layers
   - Styles
   - Layer/style associations
5. Every target database host and port entered during export must be reachable
   from the GeoServer server. The Python script does not test or create the
   database; GeoServer opens the datastore connection later.
6. The target database must already exist, with the entered user, password,
   schema, and required tables. For PostGIS stores, the target database needs
   the PostGIS extension and compatible schemas.
7. The server running the script must have read access to the manifest and
   write access to the directory where the JSON file is saved.

For a quick installation check, run:

```bash
python --version
python -m pip install -r requirements.txt
python -c "import requests; print(requests.__version__)"
```

The exporter and importer are interactive and require a terminal. If they run
on a Linux server, use `python3` and `python3 -m pip` in the commands above.

---

## Configuration

The exporter collects source credentials, the source workspace, the target
workspace name, and target database connections interactively. The importer
collects the destination GeoServer credentials and reads the remaining
configuration from the manifest.

---

## Steps

### 1. Export a manifest

Run:

```bash
python export_source_config.py
```

Enter the source GeoServer details, source workspace, target workspace name,
and target database connection details. The script writes a file such as
`imis_new_manifest.json`. The JSON includes database credentials, so keep it
secure. Each style entry includes a top-level `name`, `format`, and `css` field
when the style is CSS, together with the complete style body used by the
importer.

### 2. Create a workspace from the manifest

Run:

```bash
python create_workspace_from_manifest.py
```

Provide the manifest path and destination GeoServer credentials. The importer
asks for the current database connection for every store, so an old encrypted
`crypt1:...` password in a manifest is never treated as the current password.
The JSON does not
contain binary icon files, so keep the `icons` folder beside the importer:

```text
workspace_manifest_tool/
├── create_workspace_from_manifest.py
├── <your-manifest>.json
└── icons/
    ├── pin-blue.png
    └── treatment-plant-*.svg
```

The importer automatically uploads every file in this local `icons` folder to
the destination GeoServer at:

```text
workspaces/<target_workspace>/styles/icons/
```

You do not need to create that destination directory manually. The destination
GeoServer account must be allowed to write REST resources.

### 3. Review styles and icons

Some GeoServer styles use external SVG or PNG icons.

Previously, these icons were stored in the web application server. This caused problems during GeoServer workspace replication because GeoServer could not reliably access files stored outside its workspace.

The importer places all required icons inside the GeoServer workspace. Keep the
provided local `icons` folder with the importer when running it.

Layer SRS and projection settings are restored from the manifest. Native and
latitude/longitude bounding boxes are recalculated by GeoServer from the target
database during feature type creation, so new manifests omit copied bounding
box values. The `srs` value is retained.

Feature attributes are also discovered from the destination database. This
allows the destination schema to differ from the source schema without sending
stale source-only fields to GeoServer.

If a layer has no SRS in the manifest, the importer defaults it to
`EPSG:4326`.

One database connection is requested and reused for every datastore. Database
schemas are read directly from each datastore in the manifest and are not
prompted again during import.

At the end, the importer prints a `Missing resources` report for any datastore,
layer, style, or icon that could not be created or uploaded. Existing resources
are reused on the next run.

Temporary GeoServer or Cloudflare `502`, `503`, and `504` responses for GET
requests are retried automatically while the importer waits for the server to
respond.

Create the following directory:

```text
GEOSERVER_DIR/workspaces/<workspace_name>/styles/icons
```

Copy the required icon files into this directory.

#### SVG icons

Source location:

```text
public\img\svg
```

Required files:

```text
treatment-plant-cd-wwtp.svg
treatment-plant-cotreatment.svg
treatment-plant-c-wwtp.svg
treatment-plant-default.svg
treatment-plant-fstp.svg
treatment-plant-green.svg
treatment-plant-red.svg
```

#### PNG icon

Source location:

```text
public\img
```

Required file:

```text
pin-blue.png
```

A recommended directory structure is:

```text
GEOSERVER_DIR/
└── workspaces/
    └── <workspace_name>/
        └── styles/
            └── icons/
                ├── treatment-plant-cd-wwtp.svg
                ├── treatment-plant-cotreatment.svg
                ├── treatment-plant-c-wwtp.svg
                ├── treatment-plant-default.svg
                ├── treatment-plant-fstp.svg
                ├── treatment-plant-green.svg
                ├── treatment-plant-red.svg
                └── pin-blue.png
```

### 5. Update icon URLs in GeoServer styles

For every style that references an external icon using `url(...)`, replace the old web application path with a path relative to the GeoServer workspace style directory.

Example:

```css
url("icons/treatment-plant-default.svg")
```

For PNG files:

```css
url("icons/pin-blue.png")
```

The following layers/styles must be checked and updated:

1. `treatmentplants_layer_status`
2. `treatmentplants_layer_type`
3. `treatmentplants_layer_none`
4. `water_samples_layer`
5. `places_layer`

> **Important:** Apply this icon-path update to all relevant styles, including styles used by the base workspace.

### 6. Verify the imported workspace

After the import completes, verify:

- Workspace exists
- Data stores exist
- Layers are available
- Styles are available
- Default styles are assigned correctly
- Layer previews load correctly
- SVG/PNG icons are displayed correctly
- No style references point to the web application server

---

## Dynamic Style Fallback

When the source workspace contains `buildings_layer_functional_use`, the
exporter includes it in the manifest and the importer restores it. If it is
missing from the manifest, the importer creates it automatically from the
built-in CSS fallback below.

```text
buildings_layer_functional_use
```

Use the following CSS:

```css
/* Base IMIS v1.0.0 */

/* @title Residential */
[functional_use_id='1'] {
    fill: #000080;
    label: [bin];
}

/* @title Mixed (Residential, Commercial, Office uses) */
[functional_use_id='2'] {
    fill: #FF0000;
    label: [bin];
}

/* @title Educational */
[functional_use_id='3'] {
    fill: #6495ED;
    label: [bin];
}

/* @title Commercial */
[functional_use_id='5'] {
    fill: #964B00;
    label: [bin];
}

/* @title Industrial */
[functional_use_id='6'] {
    fill: #A020F0;
    label: [bin];
}

/* @title Institution */
[functional_use_id = '4'][NOT(functional_use_id is Null)],
[functional_use_id = '8'][NOT(functional_use_id is Null)],
[functional_use_id = '9'][NOT(functional_use_id is Null)],
[functional_use_id = '10'][NOT(functional_use_id is Null)],
[functional_use_id = '11'][NOT(functional_use_id is Null)],
[functional_use_id = '13'][NOT(functional_use_id is Null)] {
    fill: #FFFF00;
    label: [bin];
}

/* @title Others */
[functional_use_id = '7'][NOT(functional_use_id is Null)],
[functional_use_id = '12'][NOT(functional_use_id is Null)],
[functional_use_id = '14'][NOT(functional_use_id is Null)] {
    fill: #660033;
    label: [bin];
}

*:fill {
    stroke: gray;
}

* {
    fill-opacity: 0.4;
    stroke: #000001;
    stroke-width: 0.01;
    stroke-opacity: 0.8;
    stroke-linejoin: bevel;
}
```

After creating the style:

1. Save the style.
2. Validate the style in GeoServer.
3. Assign it to the appropriate `buildings_layer_functional_use` layer.
4. Open Layer Preview and confirm that the categorized colors and labels render correctly.

---

## Important Style Replication Update

### Issue

Custom icons used by GeoServer styles were previously stored inside the web application server.

This made the styles dependent on files outside the GeoServer workspace and could cause missing icons when cloning or replicating a workspace.

### Solution

Keep all icons required by GeoServer styles inside:

```text
GEOSERVER_DIR/workspaces/<workspace_name>/styles/icons
```

All style icon references should use relative paths such as:

```css
url("icons/treatment-plant-green.svg")
```

or:

```css
url("icons/pin-blue.png")
```

Do not reference icon files using locations from the web application server.

---

## Post-Clone Checklist

After cloning a workspace, confirm the following:

- [ ] Source and destination settings in `CONFIG` are correct.
- [ ] Custom layers are included in `DEFAULT_STYLE_MAP`.
- [ ] Workspace was created successfully.
- [ ] Data stores were cloned successfully.
- [ ] Layers were cloned successfully.
- [ ] Styles were cloned successfully.
- [ ] Default styles are assigned to the correct layers.
- [ ] `styles/icons` exists inside the destination workspace.
- [ ] Required SVG files are present.
- [ ] `pin-blue.png` is present.
- [ ] All external icon URLs were replaced with workspace-relative URLs.
- [ ] `treatmentplants_layer_status` was verified.
- [ ] `treatmentplants_layer_type` was verified.
- [ ] `treatmentplants_layer_none` was verified.
- [ ] `water_samples_layer` was verified.
- [ ] `places_layer` was verified.
- [ ] `buildings_layer_functional_use` exists, either from the manifest or as a manual fallback.
- [ ] Layer Preview was tested for the cloned layers.
- [ ] No styles depend on files located on the web application server.

---

## Current Limitation

The scripts have been used with local Python installations on Windows.

Server-side execution has not yet been tested. Before using these scripts directly on a production or Linux server, test them first in a development or staging environment.
