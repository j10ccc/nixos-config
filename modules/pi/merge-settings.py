import json
import os
import pathlib
import sys
import tempfile


source, target = map(pathlib.Path, sys.argv[1:])
settings = json.loads(target.read_text()) if target.exists() else {}
settings.update(json.loads(source.read_text()))
content = json.dumps(settings, indent=2) + "\n"
if not target.exists() or target.read_text() != content:
    target.parent.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", dir=target.parent, delete=False) as output:
            temporary = pathlib.Path(output.name)
            output.write(content)
        os.replace(temporary, target)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
