#!/bin/sh

set -e

#  sendToFabric.sh
#  aBike—Lyon
#
#  Created by Clément Padovani on 2/13/16.
#  Copyright © 2016 Clement Padovani. All rights reserved.

releaseConfig="Release"
screenshotsConfig="Screenshots"

if [ "$releaseConfig" = "${CONFIGURATION}" ]; then

echo "Release"

if [ "$screenshotsConfig" = "${CONFIGURATION}" ]; then

echo "Screenshots"

exit

fi

if [[ "${SDKROOT}" == *Simulator* ]]
then

echo "Simulator"
exit
fi

echo "Not simulator"

"${PODS_ROOT}/Fabric/run" 9dfaba5dced813ed66e1f2291c22464b97fe3be3 9b9ce5921627b461c0347829020735887526444b662d5db383e852f43e932b00

fi
