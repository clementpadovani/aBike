$:.unshift File.dirname("../.." + __FILE__)

require '../Various/version.rb'

module CPaBike

VERSION = '3.1.0'

RELEASE_NOTES = ({

  'en-US' => "Bug fixes",
  'fr-FR' => "Corrections de bugs",
  'en-GB' => "Bug fixes"

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
	add_id_info_uses_idfa: false,
  demo_user: "",
  demo_password: ""
})

end
