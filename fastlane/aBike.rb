$:.unshift File.dirname("../.." + __FILE__)

require '../Various/version.rb'

module CPaBike

VERSION = '3.0.5'

RELEASE_NOTES = ({

	'en-US' => "Bug fixes",
	'fr-FR' => "Corrections de bugs",
	'en-GB' => "Bug fixes"

})

SUBMIT_FOR_REVIEW = false

AUTOMATIC_RELEASE = true

SUBMISSION_INFORMATION = ({
	add_id_info_uses_idfa: false
})

end
