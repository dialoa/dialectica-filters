--[[-- # Image attributes - additional image attributes in
  Pandoc's markdown

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2022 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
]]
function Image(img)
	local is_inline = true

	-- check whether Pandoc interpreted the image as a figure
	-- if it does, it applies "fig:" to the title.
	-- Limitation: if the user has put "fig:" in an inline image,
	--		there's no easy way to tell that it's not a figure.
	if img.title:find('^fig:') then
		is_inline = false
	end

	-- center
	if is_inline and img.classes:includes('center') then

		if FORMAT:match('latex') then
			return {	
								pandoc.RawInline('latex', '\\begin{center}'),
								img,
								pandoc.RawInline('latex', '\\end{center}'),
							}

		elseif FORMAT:match('html')
						or FORMAT:match('epub') then
			img.attributes.style = img.attributes.style 
							and img.attributes.style..'margin:auto; display:block;'
							or 'margin:auto; display:block;'
			return img
		end

	end

end