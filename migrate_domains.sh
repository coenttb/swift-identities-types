#!/bin/bash

# Function to migrate a domain
migrate_domain() {
    local old_domain=$1
    local new_domain=$2
    
    echo "Migrating $old_domain to $new_domain..."
    
    # Create target directory if it doesn't exist
    mkdir -p "Sources/IdentitiesTypes/$new_domain"
    
    # Copy and rename files
    for file in Sources/IdentitiesTypes/$old_domain/*.swift; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            # Transform filename pattern
            new_filename="${filename//Identity.$old_domain/Identity.$new_domain}"
            new_filename="${new_filename//Identity.Client.$new_domain/Identity.$new_domain.Client}"
            new_filename="${new_filename//Identity.API.$new_domain/Identity.$new_domain.API}"
            new_filename="${new_filename//Identity.$new_domain.Route/Identity.$new_domain.Route}"
            new_filename="${new_filename//Identity.View.$new_domain/Identity.$new_domain.View}"
            
            cp "$file" "Sources/IdentitiesTypes/$new_domain/$new_filename"
            echo "  Copied $filename -> $new_filename"
        fi
    done
    
    # Handle subdirectories (like MFA subdirs)
    for subdir in Sources/IdentitiesTypes/$old_domain/*/; do
        if [ -d "$subdir" ]; then
            subdir_name=$(basename "$subdir")
            mkdir -p "Sources/IdentitiesTypes/$new_domain/$subdir_name"
            
            for file in "$subdir"*.swift; do
                if [ -f "$file" ]; then
                    filename=$(basename "$file")
                    cp "$file" "Sources/IdentitiesTypes/$new_domain/$subdir_name/$filename"
                    echo "  Copied $subdir_name/$filename"
                fi
            done
        fi
    done
}

# Migrate all domains
migrate_domain "Creation" "Create"
migrate_domain "Deletion" "Delete"
migrate_domain "Reauthorization" "Reauthorize"

echo "Migration complete!"