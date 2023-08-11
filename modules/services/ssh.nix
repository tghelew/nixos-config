{ options, config, lib, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.ssh;
in {
  options.modules.services.ssh = {
    enable = mkBoolOpt false;
    passwordAuthentication = mkBoolOpt false;
    ports = with types; mkOption {
      type = listOf port;
      default = [ 2203 ];
      defaultText = literalExpression "[ 2203 ]";
      example = literalExpression "[ 2203 ]";
      description = lib.mdDoc "Openssh ports to use";
    };
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = cfg.ports;
      settings = {
        KdbInteractiveAuthentication = false;
        PasswordAuthentication = cfg.passwordAuthentication;
      };
    };

    user.openssh.authorizedKeys.keys =
      if elem config.user.name [ "tghelew" "thierry" ]
      then [
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQ+XlLbdjPG7I/ZjLreNDUWtTdpIKcBzTKXsH/vb09NmuLIBcQa0fX+beRKaEcO6b73iwD1nU4tMDdPGWVaC6aaE1+zmWkdjfoxhPQANeokBARTwb/Z+qq0KEskiWZhvTS/Xk/sT5ZlD+kf/KQhKEDUCuiJMjopXJ/5v15Meiuv2SXiuY3ArmFasYnAJMQITYHRrJbAv1jmaPUz+tXZao+1fL5Y+xwgz2MNzNUGPXJqMYrw43bCLzQwU5jACx0aUA6wB7DXyhhIMPRhOcYNCeBbyoSgwmw4ClZeMlcEApeaGprNwboAHirCOywxBDc9ulpgDEFJVc8mibChwVvQWx4v6rW823COJYR2QLXmeNCB33g+6GOhJh71z2y/SR7IlrBaVChVI+E3y5y2lu6L1NZ0QlSUZouqKspYsHKj9DcaVrLEkcfRIhGP6VGDAHyEUp7SPCvPwKiyeYPU1CYP5MrW1JKDtuk98pxME6/OBPBNfKChP4meXVcpNlt9HhyjKlPZ+BKr9ph1ZBpwLzOJtu00cZBMote5wqyvPbuqcT+OmQ6t0UGaPLnVJEHhsgtplMswax+CeUUOP4ZmftHaUr0JgFOVntYYnlzImUQnbILXJOnp1bus/K0RmToQ6B6CC0r1yDV1IXHZ4akTc8m5v7Zhtguyp2aPXfkVi0aTacJEQ== admin@ghelew.net
"
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/oHOQOYcg82qgDzPXL7p+UoJHrBUxQhwtupbD8KL6fBDNw5kADLyk0NrRxBTes91RE+LdrdY+C8RLps0fZYg6qE9C4Y9SC72SIpMEfTwBSf25YeOsSjRi+DUQsDX7CDCbElCMjdB+i1x9+YuhgxZvXUsCYOsgniPdI5DaVhkFBXbm01y4ATRKc35jDjxFv2dj+ePjKDTWYV+UGjCVKe+mjntF2IpL7MytE4o/YUkGcL7DXvf9l53Ma2eF1G1R8ZdFpS+X8o12Z2Toue2QMBwU3IYUuNfkk9202t78EB7VkZ770sdmjYmIQ5V4pzLTXyNYjJFs5cRH3dE2yMXgb3w4P4IIM2SlRsXGNK7eEVsWUzviarGcV5WNGfjwj1V4is3kky4h9k+AhhG2tHcY9oKBxPBE8ZJvmQWOH/E0w+aGOKp4JvJHvfiDsIqTpmMh4jtZZOhWfE/ShskIsPhvqsZn3L4WQjWuzO0b8s69G+7+CKh45fU3v1nvOk0Bc3ArFfaWnjWJMV/eU5PlpiE27I1OFVw4G0WIDk08pAKP+Wj8n8f+xQbhvbBT8kaIsp+7B0EbkxsI7edpHQULgQe4iR0TlUxBl/AW9uuov/sRPYKrSrJjOip4kNz0SrQxTGwysoH8zFoelBXiqC4zk+bC2tmNBsOBWpA4jh0+ru5WS3j9LQ== rootvm@ghelew.net
"
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+4xTGwlCatE99/NvEHjdPaq2y/IevAjeqUHniEgqAn+8T5lsHcISK0rIM9I6Wt8pl+IMKbBSOAj0emvDo9dmOng1LdWsC0WE4MZJFvXwCIzYo8hVhgdqQaAwFoZvRupkKUN8JtWIhJXv4HT+4uOGpO9WZtjUDTfJZVzdurSrpSigkYJZDrm1Wa7GQiEj4F+R7vdHJhh1zQjZHFpRvI1a/zIQ0qg+IAnYH0TOPQO61RrMrxGZKBrM5aUPRyhY/FIS2et9mm4UlCKAKC2mq4V5Jeu80DVtPXI56uVBEG05c9Jdr+bs3ScVZrw26q620QBxmR4QxYwyRcjOEWx7e4Mq5FE5h+ZZEhcFkOB9J95iBsveso/rx/JhW3SPQXiFKmdhiD/ASl2CXCotyv1OKt1d+gC0+3DK5NqG3A1jsP6byy6ZgnrkjJ5l9aHcK/8D9aMw3LxTe2TJUtULU3AZRhxepJqf9+mOPfui6MSJuV3gFVr44VDOqoQIketSzsyHG801ihqDGykCr5MMEZ71uIqPz8XeybafGZYsvfnDaNYfIHiAVt3QdP5ohVqRprLukkU7Ww9oha4epKcv+syk+o0Iw/iGFwTc+T2365cVAiqG2Bv0TBEH/WhM4L3vdu0ClfDbQ59OyDwEPe6CbB1f4rhdoFvAmz2g55L7uwcaJUrAlWQ== thierry@nemesis"

           ]
      else [];
  };
}
