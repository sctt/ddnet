Curl = {
	OptFind = function (name, required)
		local check = function(option, settings)
			option.value = false
			option.lib_path = nil

			if IsNegativeTerm(ScriptArgs[name .. ".use_pkgconfig"]) then
				option.use_pkgconfig = false
			elseif IsPositiveTerm(ScriptArgs[name .. ".use_pkgconfig"]) then
				option.use_pkgconfig = true
			end

			if family ~= "windows" and ExecuteSilent("pkg-config libcurl") == 0 then
				option.value = true
				if option.use_pkgconfig == nil then
					option.use_pkgconfig = true
				end
			end

			if option.use_pkgconfig == nil then
				option.use_pkgconfig = false
			end

			if platform == "win32" then
				option.value = true
			elseif platform == "win64" then
				option.value = true
			elseif platform == "macosx" and string.find(settings.config_name, "32") then
				option.value = true
			elseif platform == "macosx" and string.find(settings.config_name, "64") then
				option.value = true
			elseif platform == "linux" and arch == "ia32" then
				option.value = true
			elseif platform == "linux" and arch == "amd64" then
				option.value = true
			end
		end

		local apply = function(option, settings)
			if option.use_pkgconfig == true then
				settings.cc.flags:Add("`pkg-config --cflags libcurl`")
				settings.link.flags:Add("`pkg-config --libs libcurl`")
			else
				settings.cc.includes:Add("ddnet-libs/curl/include")

				if platform == "macosx" then
					settings.link.libs:Add("curl")
					settings.link.frameworks:Add("Foundation")
					settings.link.frameworks:Add("Security")
				elseif family ~= "windows" then
					settings.link.libs:Add("curl")
					settings.link.libs:Add("ssl")
					settings.link.libs:Add("crypto")
				end

				if platform == "win32" then
					settings.link.libpath:Add("ddnet-libs/curl/windows/lib32")
				elseif platform == "win64" then
					settings.link.libpath:Add("ddnet-libs/curl/windows/lib64")
				elseif platform == "macosx" and string.find(settings.config_name, "32") then
					settings.link.libpath:Add("ddnet-libs/curl/mac/lib32")
				elseif platform == "macosx" and string.find(settings.config_name, "64") then
					settings.link.libpath:Add("ddnet-libs/curl/mac/lib64")
					settings.link.libpath:Add("ddnet-libs/curl/mac/lib64")
				elseif platform == "linux" then
					settings.link.libpath:Add("ddnet-libs/curl/linux/lib64")
					settings.link.libpath:Add("ddnet-libs/curl/linux/lib32")
				end
			end
		end

		local save = function(option, output)
			output:option(option, "value")
			output:option(option, "use_pkgconfig")
		end

		local display = function(option)
			if option.value == true then
				if option.use_pkgconfig == true then return "using pkg-config" end
				return "using bundled libs"
			else
				if option.required then
					return "not found (required)"
				else
					return "not found (optional)"
				end
			end
		end

		local o = MakeOption(name, 0, check, save, display)
		o.Apply = apply
		o.include_path = nil
		o.lib_path = nil
		o.required = required
		return o
	end
}
