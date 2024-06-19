@tool
class_name ICOGenerator


static func generate(filepath: String, image_items: Array[ImageItem]) -> Error:
	# Calculate file size (without raw image data at the end) in bytes:
	var size := 6 + image_items.size() * 16
	
	# Create the buffer for the ICO file:
	var buf := PackedByteArray([])
	buf.resize(size)
	
	# Header:
	buf.encode_u16(0, 0) # Reserved; always zero
	buf.encode_u16(2, 1) # image type (1 = ICO)
	buf.encode_u16(4, image_items.size()) # Number of images
	
	var offset := 6
	
	# Write image icon entries:
	var image_data_offset := size
	for image_item in image_items:
		var meta := PNGMeta.new(image_item.image_buffer)
		if meta.error != OK:
			return meta.error
		buf.encode_u8(offset + 0, meta.width)
		buf.encode_u8(offset + 1, meta.height)
		buf.encode_u8(offset + 2, 0) # Colors in palette
		buf.encode_u8(offset + 3, 0) # Reserved; always zero
		buf.encode_u16(offset + 4, 0) # Color plane
		buf.encode_u16(offset + 6, meta.bit_depth) # Bits per pixel
		buf.encode_u32(offset + 8, image_item.image_buffer.size()) # Image data size
		buf.encode_u32(offset + 12, image_data_offset) # Offset to image data in the file
		offset += 16
		image_data_offset += image_item.image_buffer.size()
	
	# Write image data:
	for image_item in image_items:
		buf += image_item.image_buffer
	
	# Write file:
	var file := FileAccess.open(filepath, FileAccess.WRITE)
	if FileAccess.get_open_error() != OK:
		return FileAccess.get_open_error()
	
	file.store_buffer(buf)
	
	file.close()
	return OK


class PNGMeta:
	var width: int
	var height: int
	var bit_depth: int
	var color_type: int
	var compression_method: int
	var filter_method: int
	var interlace_method: int
	var buffer: PackedByteArray
	var error := OK
	
	func _init(buf: PackedByteArray):
		buffer = buf
		error = _decode()
	
	func _decode() -> Error:
		# Ensure PNG header is correct:
		var header := buffer.slice(0, 8)
		var expected_header := PackedByteArray([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])
		if header != expected_header:
			push_error("Invalid PNG header")
			return ERR_FILE_UNRECOGNIZED
		
		# Read the IHDR chunk (always first chunk of PNG):
		return _read_ihdr_chunk()
	
	func _read_ihdr_chunk() -> Error:
		var offset := 8
		
		# StreamPeerBuffer is used to read big-endian values
		var peer := StreamPeerBuffer.new()
		peer.big_endian = true
		peer.data_array = buffer.slice(offset, offset + 4)
		offset += 4
		var length := peer.get_u32()
		if length != 13:
			push_error("Invalid first chunk length for PNG: %d (expected 13)" % length)
			return ERR_FILE_UNRECOGNIZED
		
		var chunk_type = buffer.slice(offset, offset + 4)
		var expected_chunk_type = "IHDR".to_ascii_buffer()#PackedByteArray(['I', 'H', 'D', 'R'])
		offset += 4
		if chunk_type != expected_chunk_type:
			push_error("Invalid first chunk type for PNG")
			return ERR_FILE_UNRECOGNIZED
		
		peer = StreamPeerBuffer.new()
		peer.big_endian = true
		peer.data_array = buffer.slice(offset, offset + 13)
		width = peer.get_u32()
		height = peer.get_u32()
		bit_depth = peer.get_u8()
		color_type = peer.get_u8()
		compression_method = peer.get_u8()
		filter_method = peer.get_u8()
		interlace_method = peer.get_u8()
		
		return OK
