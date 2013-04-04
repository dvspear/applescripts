-- Originally from https://discussions.apple.com/thread/2124889 --

on run {input, parameters}
	(*
make new folders from file creation dates (if needed), then move document files into their respective new folders
if no container is specified (missing value), the new folder will be created in the containing folder of the item
if the container is not a valid path (and not missing value), one will be asked for
input: a list of Finder items (aliases) to move
output: a list of the Finder items (aliases) moved
*)
	
	set output to {}
	set SkippedItems to {} -- this will be a list of skipped items (errors)
	set TheContainer to "" -- a Finder path to a destination folder, or missing value for the source folder
	if TheContainer is not missing value then try -- check the destination path
		TheContainer as alias
	on error
		set TheContainer to (choose folder with prompt "Where do you want to move the items?")
	end try
	
	tell application "Finder" to repeat with AnItem in the input -- step through each item in the input
		if TheContainer is not missing value then -- move to the specified folder
			set {class:TheClass, name:TheName, name extension:TheExtension} to item AnItem
		else -- move to the source folder
			set {class:TheClass, name:TheName, name extension:TheExtension, container:TheContainer} to item AnItem
		end if
		if TheClass is document file then try -- just documents
			set TheDate to text 1 thru 10 of (creation date of AnItem as «class isot» as string) -- YYYY-MM-DD
			try -- check if the target folder exists
				get ("" & TheContainer & TheDate) as alias
			on error -- make a new folder
				make new folder at TheContainer with properties {name:TheDate}
			end try
			-- duplicate AnItem to the result
			move AnItem to the result
			set the end of output to (result as alias) -- the new file alias
		on error -- permissions, etc
			-- set the end of SkippedItems to (AnItem as text) -- the full path
			set the end of SkippedItems to TheName -- just the name
		end try
	end repeat
	
	--ShowSkippedAlert for SkippedItems
	return the output -- pass the result(s) to the next action
end run



--to ShowSkippedAlert for SkippedItems
--if SkippedItems is not {} then set {AlertText, TheCount} to {"Error with AppleScript action", count SkippedItems}
--if TheCount is greater than 1 then
--	set theMessage to (TheCount as text) & space & " items were skipped:"
--else
--	set theMessage to "1 " & " item was skipped:"
--end if
--set {TempTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, return}
--set {SkippedItems, AppleScript's text item delimiters} to {SkippedItems as text, TempTID}
--if button returned of (display alert AlertText message (theMessage & return & SkippedItems) alternate button "Cancel" default button "OK") is "Cancel" then
--	error number -128
--end if
--return
--end ShowSkippedAlert
