with timeout of 3600 seconds
	tell application "Finder"
		set destination to choose folder
	end tell
	tell application "Aperture"
		set projnames to name of every project
		set settings to first export setting whose name is "JPEG - Original Size"
		repeat with projname in projnames
			tell application "Finder"
				if not (exists folder projname of destination) then
					make new folder at destination with properties {name:projname}
				end if
			end tell
			tell application "Aperture"
				set albums to albums in project projname
				repeat with thealbum in albums
					tell thealbum
						set images to every image version as list
						set albumname to name of thealbum
						tell application "Finder"
							set folderexists to exists folder albumname in folder projname of destination
							if not folderexists then
								make new folder at folder p of destination with properties {name:albumname}
							end if
							set destination to folder albumname in folder projname in destination as alias
						end tell
						if not folderexists then
							tell thealbum
								export images using settings to destination
							end tell
						end if
					end tell
				end repeat
			end tell
		end repeat
	end tell
end timeout