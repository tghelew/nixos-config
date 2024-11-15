let
  atumba = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPBE4Wnj8F0mOI5PrAkNzAsTA4RFrkIIuCj1U/5+67G3 root@atumba";
  user ="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+4xTGwlCatE99/NvEHjdPaq2y/IevAjeqUHniEgqAn+8T5lsHcISK0rIM9I6Wt8pl+IMKbBSOAj0emvDo9dmOng1LdWsC0WE4MZJFvXwCIzYo8hVhgdqQaAwFoZvRupkKUN8JtWIhJXv4HT+4uOGpO9WZtjUDTfJZVzdurSrpSigkYJZDrm1Wa7GQiEj4F+R7vdHJhh1zQjZHFpRvI1a/zIQ0qg+IAnYH0TOPQO61RrMrxGZKBrM5aUPRyhY/FIS2et9mm4UlCKAKC2mq4V5Jeu80DVtPXI56uVBEG05c9Jdr+bs3ScVZrw26q620QBxmR4QxYwyRcjOEWx7e4Mq5FE5h+ZZEhcFkOB9J95iBsveso/rx/JhW3SPQXiFKmdhiD/ASl2CXCotyv1OKt1d+gC0+3DK5NqG3A1jsP6byy6ZgnrkjJ5l9aHcK/8D9aMw3LxTe2TJUtULU3AZRhxepJqf9+mOPfui6MSJuV3gFVr44VDOqoQIketSzsyHG801ihqDGykCr5MMEZ71uIqPz8XeybafGZYsvfnDaNYfIHiAVt3QdP5ohVqRprLukkU7Ww9oha4epKcv+syk+o0Iw/iGFwTc+T2365cVAiqG2Bv0TBEH/WhM4L3vdu0ClfDbQ59OyDwEPe6CbB1f4rhdoFvAmz2g55L7uwcaJUrAlWQ== thierry@nemesis
";
  keys = [ atumba user ];
in
{
  # Private ssh keys
  "id_admin.age" = {
    publicKeys = keys;
    mode = "600";
    path = "~/.ssh/private/id_admin";
    symlink = false;
  };

  "id_github.age" = {
    publicKeys = keys;
    mode = "600";
    path = "~/.ssh/private/id_github";
    symlink = false;
  };

  "id_rootvm.age" = {
    publicKeys = keys;
    mode = "600";
    path = "~/.ssh/private/id_rootvm";
    symlink = false;
  };

  "id_rsa.age"= {
    publicKeys = keys;
    mode = "600";
    path = "~/.ssh/private/id_rsa";
    symlink = false;
  };

  #gpg secret keys
  "secret_ghelew_net.age" = {
    publicKeys = keys;
    mode = "600";
    symlink = true;
  };
}
