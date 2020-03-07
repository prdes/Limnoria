local volumes() = [
    {
        "name": "python_install",
        "path": "/usr/local/"
    }
];
local limnoria_build(image_tag, use_opt_deps) = {
    kind: "pipeline",
    type: "docker",
    name: std.strReplace(image_tag, ":", "") + if use_opt_deps then "-withoptdeps" else "-nooptdeps",
    steps:
        std.prune([
            if use_opt_deps then {
                "name": "install-deps",
                "image": image_tag,
                "commands": [
                    "pip install -vr requirements.txt",
                    "pip install -v git+https://github.com/ProgVal/irctest.git",
                    "echo y | pip uninstall limnoria || true",
                ],
                "volumes": volumes()
            },
            {
                "name": "install",
                "image": image_tag,
                "commands": [
                    "python setup.py install"
                ],
                "volumes": volumes()
            },
            {
                "name": "test",
                "image": image_tag,
                "commands": [
                    "supybot-test test -v --plugins-dir=./plugins/ --no-network",
                ],
                "volumes": volumes()
            },
            if use_opt_deps then {
                "name": "irctest",
                "image": image_tag,
                "commands": [
                    # Workaround limnoria refusing to run as root by default
                    "adduser --disabled-password --gecos '' limnoria",
                    "su limnoria -c 'cd $HOME && python -m irctest irctest.controllers.limnoria'",
                ],
                "volumes": volumes()
            },
        ]),
    volumes: [
        {
            name: "python_install",
            temp: {}
        },
    ],
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
