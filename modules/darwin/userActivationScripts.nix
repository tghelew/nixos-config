{ config, lib, pkgs, ... }:

with lib;
let
  addAttributeName = mapAttrs (a: v: v // {
    text = ''
      #### User Activation script snippet ${a}:
      _localstatus=0
      ${v.text}

      if (( _localstatus > 0 )); then
        printf "Activation script snippet '%s' failed (%s)\n" "${a}" "$_localstatus"
      fi
    '';
  });

  scriptOptions = with types; either str (submodule
    {
      options = {
        text = mkOption {
          type = lines;
          description = lib.mDoc "the content of the script.";
        };
        deps = mkOption {
          internal = true;
          type = listOf str;
          default = [];
          desciption = lib.mdDoc "List of dependencies. Used internally only! Has no effets outside.";
        };
      };
    });
in
{
  ###### interface
  options = {
    system.userActivationScripts = mkOption {
      default =  {};

      example = literalExpression ''
          {
            setupTlux {
              text = '''
                  ln -s "${XDG_CONFIG_HOME}/emacs ~/.emacs.d"
              ''';
            };
          }
      '';

      description = lib.mdDoc ''
        A set of shell script fragments that are executed by launchd in attribute
        ``` extraUserActivation```.
      '';

      type = with types; attrsOf (scriptOptions);
      apply = set: {
        script = ''
          ${
            let
              set' = mapAttrs (n: v: if isString v then noDepEntry v else v) set;
              withWrapper = addAttributeName set';
            in textClosureMap id (withWrapper) (attrNames withWrapper)
          }
        '';
      };

    };
  };

  ###### implementation

  config = {

    system.activationScripts.extraUserActivation.text =
      config.system.userActivationScripts.script;
  };
}
