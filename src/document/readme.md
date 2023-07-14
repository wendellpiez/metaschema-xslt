# Metaschema Documentation Production

Metaschema in, documentation out.

## Scripts

The scripts are written in `bash` and rely on [Apache Maven](https://maven.apache.org/) for Java dependency management.

### `mvn-schemadocs-testsite-xpl.sh`

Produces a set of interlinked HTML files documenting the models (XML and object/JSON) for a metaschema, in a subdirectory.

```
> ./mvn-schemadocs-html-xpl.sh a-metaschema.xml metaschemaA docs METASCHEMA_XML SCHEMA_NAME OUTPUT_DIR
```

where

- the script `./mvn-schemadocs-html-xpl.sh` is available (in the directory or on the system path)
- `a-metaschema.xml` is a metaschema (top-level module) as a relative path (file URI)
- `metaschemaA` is the label to use in the documentation produced (file names and links)
- `docs` is a *relative* path (URI syntax) for writing serialized outputs (HTML files)

Assuming the incoming metaschema is valid, correct, and correctly linked (imports resolved), HTML file outputs are written to the indicated subdirectory.

The result file names are defined in the underlying XProc, `METASCHEMA-HTML-DOCS.xpl`.

### `mvn-schemadocs-debug-xpl.sh`

This script invokes the base 'traceable' XProc, `METASCHEMA-DOCS-TRACE.xpl`. By managing exposed ports (now binding to `/dev/null` for intermediate results and file paths for HTML results) through this script, intermediate and final outputs can be examined and assessed. Use for debugging.

As set up, this script writes outputs similarly to `mvn-schemadocs-testsite-xpl.sh`, except without hardcoding file names and writing to a path.

## Pipelines

All these pipelines have a primary input source port named `METASCHEMA`, which should be provided with a valid metaschema whose imports are resolvable and valid.

### `METASCHEMA-DOCS-DIVS-write.xpl`

Given a `path` to write to and a key name (schema name), this pipeline serializes and writes a set of documentation rooted at HTML `div` elements, suitable for ingestion into Hugo or any other HTML-based publishing system.

NB: Markdown can be acquired for docs by reducing this HTML to Markdown. Make inquiries if this is of use.

### `METASCHEMA-DOCS-DIVS.xpl`

For ease of configurability, this pipeline works like `METASCHEMA-DOCS-TESTSITE-write.xpl` except Given a `path` to write to and a key name (schema name), this pipeline serializes and writes a set of documentation rooted at HTML `div` elements, suitable for ingestion into Hugo or any other HTML-based publishing system.

NB: Markdown can be acquired for docs by reducing this HTML to Markdown. Make inquiries if this is of use.

### `METASCHEMA-DOCS-TESTSITE-write.xpl`

Just like `METASCHEMA-DOCS-DIVS.xpl`, except this pipeline writes HTML files into a path provided at runtime.

Use this pipeline to produce a set of standalone documentation ready to preview and use.

Both these pipelines include the base pipeline `METASCHEMA-DOCS-TRACE.xpl` as a defined step, and invoke it with metaschema input while configuring its runtime.

### `METASCHEMA-DOCS-TRACE.xpl`

The base pipeline called by the HTML rendering pipeline, exposing ports for debugging,
