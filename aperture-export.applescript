-- assumption, nothing done at the level passed in. 
-- assumption. folders contain subfolders and projects. projects may contain albums. If albums present, export those
-- So need to look for all sub folders and all projects
-- sub folders do a recursive call
-- projects do their own function which will check for albums, 
-- if albums present then export by album

-- starts by finding a folder which starts with "All" and works recursively from there

with timeout of 86400 seconds
	tell application "Aperture"
		-- clean out the base directory
		do shell script "rm -fr /Users/tspear-local/Documents/JAlbum/ExportData"
		do shell script "mkdir /Users/tspear-local/Documents/JAlbum/ExportData"
		
		set basedir to alias "Macintosh HD:Users:tspear-local:Documents:JAlbum:ExportData:"
		
		set allFolders to the name of every folder of library 1
		repeat with _folder in allFolders
			if (_folder starts with "All") then
				my exportFolder(_folder, basedir)
			end if
		end repeat
	end tell
	
	-- build the album html and publish it
	do shell script "/Users/tspear-local/publish-pics.sh"
end timeout

on exportFolder(_rootFolder, _basedir)
	tell application "Aperture"
		-- deal with the sub projects
		set _subProjects to the name of every project in folder _rootFolder
		repeat with _subProject in _subProjects
			my exportProjectOrAlbums(_subProject, _basedir)
		end repeat
		
		-- find all the sub folders		
		set _subFolders to the name of every folder in folder _rootFolder
		repeat with _subFolder in _subFolders
			-- create the folder which contains it all for this tier
			tell application "Finder"
				make new folder at folder _basedir with properties {name:_subFolder}
				set _subBasedir to folder _subFolder in _basedir as alias
			end tell
			
			-- now call the sub folder recursively
			my exportFolder(_subFolder, _subBasedir)
			
		end repeat
	end tell
end exportFolder

on exportProjectOrAlbums(_project, _basedir)
	tell application "Aperture"
		
		set settings to first export setting whose name is "JPEG - Original Size"
		
		-- add check for albums, if so do alternate
		tell project _project
			-- create a folder for the project
			tell application "Finder"
				make new folder at folder _basedir with properties {name:_project}
				set _projectFolder to folder _project in _basedir as alias
			end tell
			
			-- if (exists album in _project) then
			if (_project contains album) then
				-- loop through each album and export
				set _albums to every album in _project
				repeat with _album in _albums
					tell album _album
						-- export the album
						set _images to every image version as list
						tell application "Finder"
							make new folder at folder _projectFolder with properties {name:_album}
							set destination to folder _album in _projectFolder as alias
						end tell
						export _images using settings to destination
					end tell
				end repeat
			else
				-- export the project
				set _images to every image version as list
				export _images using settings to _projectFolder
				
			end if
			
		end tell
	end tell
end exportProjectOrAlbums
