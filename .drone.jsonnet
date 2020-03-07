local limnoria_build(image_tag, use_opt_deps) = {
    kind: "pipeline",
    type: "docker",
    name: std.strReplace(image_tag, ":", "") + if use_opt_deps then "-withoptdeps" else "-nooptdeps",
    steps:
        [
            {
                "name": "test",
                "image": image_tag,
                "commands": std.prune([
                    if use_opt_deps then "pip install -vr requirements.txt",
                    if use_opt_deps then "pip install -v git+https://github.com/ProgVal/irctest.git",
                    if use_opt_deps then "echo y | pip uninstall limnoria || true",

                    "python setup.py install",

                    "supybot-test test -v --plugins-dir=./plugins/ --no-network",
                    if use_opt_deps then "python -m irctest irctest.controllers.limnoria",
                ])
            },
        ]
};

[
    # We only need one test for running without optional deps
    limnoria_build("python:3.7", false),

    limnoria_build("python:3.4", true),
    limnoria_build("python:3.5", true),
    limnoria_build("python:3.6", true),
    limnoria_build("python:3.7", true),
    limnoria_build("python:3.8", true),
    limnoria_build("python:3.9-rc", true),
    limnoria_build("pypy:3", true),
]
