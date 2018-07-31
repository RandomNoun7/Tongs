Deploy Module {
  By PSGalleryModule {
    FromSource .\test\module\Tongs
    To PSGallery
    WithOptions @{
      ApiKey = $ENV:PSGalleryKey
    }
  }
}