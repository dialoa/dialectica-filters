function Pandoc(doc)
	print(os.getenv('PDFLATEX'))
	print(dump(PANDOC_READER_OPTIONS))
end

function dump(o)
	if type(o)=='string' then
		return o
	elseif type(o)=='number' then
		return(tostring(o))
	elseif type(o)=='boolean' then
		if o then return 'true' else return 'false' end
	elseif type(o)=='table' or type(o)=='userdata' then
		local str = ''
		for k,v in pairs(o) do
			str = str .. '[' .. k .. ']: ' .. dump(v) .. '\n'
		end
		return str
	else
		return ''
	end
end