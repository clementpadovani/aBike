$:.unshift File.dirname("../.." + __FILE__)

require '../Various/version.rb'

module CPaBike

VERSION = '3.0.6'

# RELEASE_NOTES = ({
# 
# 	'en-US' => "Bug fixes",
# 	'fr-FR' => "Corrections de bugs",
# 	'en-GB' => "Bug fixes"
# 
# })

RELEASE_NOTES = ({

	'en-US' => "- Removed Ads\n- Bug fixes",
	'fr-FR' => "- Retrait des pubs\n- Corrections de bugs",
	'en-GB' => "- Removed Ads\n- Bug fixes"

})

SUBMIT_FOR_REVIEW = false

AUTOMATIC_RELEASE = true

SUBMISSION_INFORMATION = ({
	add_id_info_uses_idfa: false
})

end
