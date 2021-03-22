--[[-- # Scholarly-format - a Pandoc Lua filter for creating academic
	journal templates

To be used in tandem with Albert Krewinkel's scholarly-metadata filter. 

This filter populates the document with pre-formatted metadata 
information that can be used by custom Pandoc templates to typeset
journal articles. 

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 0.1

]]




--- Main code
-- return the filter
return {
	Meta = process_meta
}