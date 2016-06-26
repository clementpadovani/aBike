$:.unshift File.dirname("../.." + __FILE__)

require '../Various/version.rb'

module CPaBike

VERSION = '3.2.0'

RELEASE_NOTES = ({

  'en-US' => "Added timer\nBug fixes",
  'fr-FR' => "Rajout d'un chrono\nCorrections de bugs",
  'en-GB' => "Added timer\nBug fixes"

})

# RELEASE_NOTES = ({
#
#   'en-US' => "- Added Apple Watch app",
#   'fr-FR' => "- Ajout d’une app Apple Watch",
#   'en-GB' => "- Added Apple Watch app"
#
# })

SUBMIT_FOR_REVIEW = false

AUTOMATIC_RELEASE = true

SUBMISSION_INFORMATION = ({
	add_id_info_uses_idfa: false
})

APP_REVIEW_INFORMATION = ({
  demo_user: "",
  demo_password: ""
})

end
