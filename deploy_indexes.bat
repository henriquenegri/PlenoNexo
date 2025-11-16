@echo off
echo Deploying Firestore indexes...
echo.
echo This will create the composite index for appointments collection
echo Fields: professionalId (ASC) + dateTime (ASC)
echo.

firebase deploy --only firestore:indexes

echo.
echo Index deployment completed!
echo.
echo You can also create the index manually at:
echo https://console.firebase.google.com/v1/r/project/pleno-nexo/firestore/indexes
pause