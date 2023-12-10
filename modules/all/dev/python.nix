# modules/dev/python.nix --- https://godotengine.org/
#
# Python's ecosystem repulses me. The list of environment "managers" exhausts
# me. The Py2->3 transition make trainwrecks jealous. But SciPy, NumPy, iPython
# and Jupyter can have my babies. Every single one.

{ config, options, lib, pkgs, my, ... }:

#FIXME: Properly support xdg
with lib;
with lib.my;
let devCfg = config.modules.dev;
    cfg = devCfg.python;
    configDir = config.nixos-config.configDir;
in {
  options.modules.dev.python = {
    enable = mkBoolOpt false;
  };

  config = mkMerge [
    (mkIf cfg.enable {
      user.packages = [
        (pkgs.python3.withPackages (ps: with ps;
          [
            pip
            ipython
            black
            setuptools
            python-lsp-server
          ] ++ python-lsp-server.optional-dependencies.all))
      ];

      environment.shellAliases = {
        py     = "python";
        py3    = "python3";
        ipy    = "ipython --no-banner";
        ipylab = "ipython --pylab=qt5 --no-banner";
      };

      env.IPYTHONDIR          = "$XDG_CONFIG_HOME/ipython";
      env.PIP_CONFIG_FILE     = "$XDG_CONFIG_HOME/pip/pip.conf";
      env.PIP_LOG_FILE        = "$XDG_DATA_HOME/pip/log";
      env.PYTHONSTARTUP       = "$XDG_CONFIG_HOME/python/pythonrc.py";
      env.PYTHON_HISTORY_FILE = "$XDG_CACHE_HOME/pythonrc-history";
      env.PYTHON_EGG_CACHE    = "$XDG_CACHE_HOME/python-eggs";
      env.JUPYTER_CONFIG_DIR  = "$XDG_CONFIG_HOME/jupyter";

      home.configFile = {
        pycodestyle.text =
          ''
           [pycodestyle]
            count = False
            max-line-length = 100
            ignore = F841
          '';

        "python/pytonrc.py".source =  "${configDir}/code/python/pythonrc.py";

      };
    }

    )
 ];
}
