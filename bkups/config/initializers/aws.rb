  ENV['AWS_SECRET_ACCESS_KEY'] = "w1CyHMksTjHwso2308XxV7Va+ULNTxfd0Yz2y5/K"
  ENV['AWS_ACCESS_KEY_ID'] = "AKIAJCTJ7WYDRGWUPFLA"


if Rails.env.development?
  ENV['BUCKET_NAME'] = "namewavesdev"
  ENV['VG_BUCKET_NAME'] = "vgnamewavesdev"
end