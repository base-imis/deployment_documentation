#!/usr/bin/env python3
"""Export a GeoServer workspace to a portable JSON manifest."""

import copy
import getpass
import json
from pathlib import Path
from urllib.parse import quote

import requests


def prompt(label, default="", secret=False, required=True):
    suffix = f" [{default}]" if default else ""
    value = getpass.getpass(f"{label}{suffix}: ") if secret else input(f"{label}{suffix}: ")
    value = value.strip() or default
    if required and not value:
        raise ValueError(f"{label} is required")
    return value


def one(value):
    if isinstance(value, dict):
        return [value]
    return value if isinstance(value, list) else []


def entries_to_dict(parameters):
    return {
        item.get("@key"): item.get("$", "")
        for item in one((parameters or {}).get("entry"))
        if isinstance(item, dict) and item.get("@key")
    }


class GeoServer:
    def __init__(self, base, username, password):
        self.base = base.rstrip("/")
        self.session = requests.Session()
        self.session.auth = (username, password)
        self.session.headers.update({"Accept": "application/json"})

    def url(self, path):
        return f"{self.base}/{path.lstrip('/')}"

    def get(self, path, raw=False):
        response = self.session.get(
            self.url(path),
            headers={"Accept": "text/plain" if raw else "application/json"},
        )
        if not response.ok:
            print(f"GET {response.url} -> {response.status_code}\n{response.text[:2000]}")
            response.raise_for_status()
        return response.text if raw else response.json()


def connection_for_store(store_name, source_parameters, shared=None):
    if shared is not None:
        return copy.deepcopy(shared)
    source = entries_to_dict(source_parameters)
    print(f"\nDatabase connection for store '{store_name}'")
    return {
        "host": prompt("Database host", source.get("host", "localhost")),
        "port": prompt("Database port", source.get("port", "5432")),
        "database": prompt("Database name", source.get("database", "")),
        "schema": prompt("Database schema", source.get("schema", "public")),
        "user": prompt("Database user", source.get("user", "")),
        "passwd": prompt("Database password", secret=True),
        "dbtype": prompt("Database type", source.get("dbtype", "postgis")),
    }


def style_body(server, workspace, style):
    name = quote(style["name"], safe="")
    metadata = server.get(
        f"rest/workspaces/{quote(workspace, safe='')}/styles/{name}.json"
    ).get("style", {})
    fmt = str(metadata.get("format", "")).lower()
    filename = str(metadata.get("filename", "")).lower()
    extension = ".css" if fmt == "css" or filename.endswith(".css") else ".sld"
    body = ""
    for suffix in (extension, extension + "?raw=true"):
        try:
            body = server.get(
                f"rest/workspaces/{quote(workspace, safe='')}/styles/{name}{suffix}",
                raw=True,
            )
        except requests.HTTPError:
            continue
        if body.strip():
            break
    return {
        "name": style["name"],
        "format": "CSS" if extension == ".css" else "SLD",
        "css": body if extension == ".css" else "",
        "listing": style,
        "metadata": {"style": metadata},
        "bodyFormat": "CSS" if extension == ".css" else "SLD",
        "body": body,
    }


def main():
    print("GeoServer workspace JSON exporter (read-only source operation)\n")
    server = GeoServer(
        prompt("Source GeoServer URL"),
        prompt("Source GeoServer username"),
        prompt("Source GeoServer password", secret=True),
    )
    source_workspace = prompt("Source workspace name")
    target_workspace = prompt(
        "Workspace name to use when this manifest is imported", source_workspace
    )
    output = Path(prompt("Output JSON file", f"{target_workspace}_manifest.json"))

    workspace_path = f"rest/workspaces/{quote(source_workspace, safe='')}.json"
    workspace = server.get(workspace_path).get("workspace", {})
    store_listing = server.get(f"{workspace_path[:-5]}/datastores.json")
    stores = one(store_listing.get("dataStores", {}).get("dataStore"))

    shared = None
    if len(stores) > 1 and prompt(
        "Use one database connection for every store? (y/N)", "N"
    ).lower() in {"y", "yes"}:
        shared = connection_for_store("all stores", {}, None)

    manifest = {
        "manifestVersion": 1,
        "source": {"server": server.base, "workspace": source_workspace},
        "target": {"workspace": target_workspace, "namespaceUri": None},
        "workspace": {
            key: value for key, value in workspace.items() if key not in {"href", "id"}
        },
        "datastores": [],
        "layers": [],
        "styles": [],
    }
    manifest["workspace"]["name"] = target_workspace

    for store_ref in stores:
        store_name = store_ref["name"]
        store_path = (
            f"{workspace_path[:-5]}/datastores/{quote(store_name, safe='')}.json"
        )
        store = server.get(store_path).get("dataStore", {})
        target_connection = connection_for_store(
            store_name, store.get("connectionParameters"), shared
        )
        datastore = copy.deepcopy(store)
        datastore.pop("href", None)
        datastore["workspace"] = {"name": target_workspace}
        datastore["targetConnectionParameters"] = target_connection
        feature_listing = server.get(f"{store_path[:-5]}/featuretypes.json")
        feature_refs = one(feature_listing.get("featureTypes", {}).get("featureType"))
        datastore["featureTypes"] = []

        for feature_ref in feature_refs:
            feature_name = feature_ref["name"]
            feature_path = (
                f"{store_path[:-5]}/featuretypes/{quote(feature_name, safe='')}.json"
            )
            feature = server.get(feature_path)
            feature_copy = copy.deepcopy(feature)
            feature_body = feature_copy.get("featureType", feature_copy)
            feature_body.pop("nativeBoundingBox", None)
            feature_body.pop("latLonBoundingBox", None)
            datastore["featureTypes"].append(feature_copy)
            layer = server.get(
                f"rest/layers/{quote(source_workspace + ':' + feature_name, safe='')}.json"
            )
            manifest["layers"].append(
                {"featureType": feature, "layer": layer, "datastore": store_name}
            )
        manifest["datastores"].append(datastore)

    styles = one(
        server.get(f"{workspace_path[:-5]}/styles.json")
        .get("styles", {})
        .get("style", [])
    )
    for style in styles:
        manifest["styles"].append(style_body(server, source_workspace, style))

    output.write_text(json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"\nWrote {output.resolve()}")
    print(
        f"Exported {len(manifest['datastores'])} stores, "
        f"{len(manifest['layers'])} layers, and {len(manifest['styles'])} styles."
    )
    print("Use create_workspace_from_manifest.py with this file to create the target workspace.")


if __name__ == "__main__":
    main()
