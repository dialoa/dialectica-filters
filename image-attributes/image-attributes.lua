--[[-- # Image attributes - additional image attributes in
  Pandoc's markdown

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2022 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1
]]
function Image(img)

	-- center
	if img.classes:includes('center') then

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
		end

	end

end