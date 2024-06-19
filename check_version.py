import sys

def main():
	if len(sys.argv) <= 1:
		print("missing version argument", file=sys.stderr)
		exit(1)
	
	version = sys.argv[1]
	plugin_version = ""
	found_plugin_version = False
	matched_version = False

	with open("addons/png_to_ico/plugin.cfg", mode="r") as plugin_cfg_file:
		lines = plugin_cfg_file.readlines()
		for line in lines:
			if line.startswith("version="):
				plugin_version = "v" + line[9:-2]
				matched_version = plugin_version == version
				found_plugin_version = True
				break
	
	if not found_plugin_version:
		print("failed to find plugin config version", file=sys.stderr)
		exit(1)

	if not matched_version:
		print(f"version mismatch (input: {version} | plugin config: {plugin_version})", file=sys.stderr)
		exit(1)
	
	print("versions matched")

if __name__ == "__main__":
	main()
