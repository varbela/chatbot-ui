#!/bin/bash
set -x

# Step 0: Replace placeholders in the SQL file
# Temporary file for storing the modified SQL file
TEMP_FILE="temp.sql"

# Path to the original SQL file
SQL_FILE="supabase/migrations/20240108234540_setup.sql"
ls -l $SQL_FILE

# Environment variables (these should be set in your Railway environment or .env file)
PROJECT_URL=${NEXT_PUBLIC_SUPABASE_URL:-http://localhost:8000}
SERVICE_ROLE_KEY=${SUPABASE_SERVICE_ROLE_KEY:-your_default_service_role_key}

# Replace placeholders in the SQL file
sed "s|PROJECT_URL_PLACEHOLDER|$PROJECT_URL|g; s|SERVICE_ROLE_KEY_PLACEHOLDER|$SERVICE_ROLE_KEY|g" $SQL_FILE > $TEMP_FILE

# Checking size of tempfile
echo "Checking the temp file:"
ls -l $TEMP_FILE

# Overwrite the original SQL file with the modified version
mv $TEMP_FILE $SQL_FILE

echo "Placeholders replaced in $SQL_FILE"

# Print the content of the SQL file to check its values
echo "Checking the modified SQL file:"
ls -l $SQL_FILE

# Step 1: Link to the Supabase project
echo "Linking to Supabase project..."
npx supabase link --project-ref $SUPABASE_REFERENCE_ID

# Check if linking was successful
if [ $? -ne 0 ]; then
    echo "Failed to link to Supabase project."
    exit 1
fi

# Step 2: Push the database changes
# URL-encode the password using Node.js to avoid logging sensitive information
ENCODED_PASSWORD=$(node -e "console.log(encodeURIComponent(process.argv[1]))" "$SUPABASE_DATABASE_PASSWORD")

# Replace [YOUR-PASSWORD] in SUPABASE_DATABASE_URL with the actual password
SUPABASE_DATABASE_URL_WITH_PASSWORD=${SUPABASE_DATABASE_URL/\[YOUR-PASSWORD\]/$ENCODED_PASSWORD}

echo "Pushing database changes to Supabase..."
npx supabase db push --db-url "$SUPABASE_DATABASE_URL_WITH_PASSWORD"

# Check if db push was successful
if [ $? -ne 0 ]; then
    echo "Failed to push database changes to Supabase."
fi

echo "Supabase operations completed successfully."
