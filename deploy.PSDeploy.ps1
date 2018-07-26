Deploy Module {
  By PSGalleryModule {
    FromSource .\test\module\puppet_testing_powershell
    To PSGallery
    WithOptions @{
      ApiKey = $ENV:PSGalleryKey
    }
  }
}