def extract_first_words_exclude_missing(input_filename, output_filename):
    try:
        with open(input_filename, 'r') as infile, open(output_filename, 'w') as outfile:
            # Write the shell script header
            outfile.write('#!/bin/bash\n\n')
            outfile.write('# List of packages to install\n')
            outfile.write('packages=(\n')
            
            for line_number, line in enumerate(infile, start=1):
                line = line.strip()
                
                # Exclude lines containing the word 'missing'
                if ' 0 ' in line:
                    continue
                
                # Remove colons from the line
                line = line.replace(':', '')
                
                words = line.split()
                
                if words:
                    # Write each package name inside the packages array
                    outfile.write(f'    "{words[0]}"\n')

            # Close the array
            outfile.write(')\n\n')
            
            # Write the installation loop
            outfile.write('# Loop through each package and install it\n')
            outfile.write('for pkg in "${packages[@]}"; do\n')
            outfile.write('    echo "Installing $pkg..."\n')
            outfile.write('    sudo pacman -S --noconfirm "$pkg"\n')
            outfile.write('done\n\n')
            outfile.write('echo "All packages installed"\n')
                
    except Exception as e:
        print(f"An error occurred: {e}")

# Replace 'file.txt' with the path to your input file
# 'install_packages.sh' is the output shell file where the results will be written
extract_first_words_exclude_missing('file.txt', 'install_packages.sh')
