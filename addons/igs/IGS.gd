extends Node
class_name Screenshot

# enum with possible key to use
enum KEYS {
	KEY_F1 = KEY_F1,
	KEY_F2 = KEY_F2,
	KEY_F3 = KEY_F3,
	KEY_F4 = KEY_F4,
	KEY_F5 = KEY_F5,
	KEY_F6 = KEY_F6,
	KEY_F7 = KEY_F7,
	KEY_F8 = KEY_F8,
	KEY_F9 = KEY_F9,
	KEY_F10 = KEY_F10,
	KEY_F11 = KEY_F11,
	KEY_F12 = KEY_F12
	}

# Exported variables
export(KEYS) var key = KEY_F12
export(String, DIR) var path = "res://screenshot"
export(bool) var create_gdignore = true
export(String) var prefix = "ss_"
export(String) var file_name = "{Y}-{M}-{D}T{i}"
export(bool) var burst = false
export(int) var burst_number = 10
export(float, 0.02, 3.0) var burst_delay = 0.1

# Image extension
const extension = ".png"

# Internal variables
var pressed : = false
var index : = 0
var timer : Timer

func _ready() -> void :
	if burst:
		# If burst is active i create the timer
		timer = Timer.new()
		timer.wait_time = burst_delay
		timer.connect("timeout", self, "screenshot")

		add_child(timer)


func _process(delta):
	# Check for pressed key
	if (Input.is_key_pressed(key) && !pressed) || Input.is_action_just_pressed("igs_screenshot"):
		if burst:
			screenshot()
			timer.start()
		else:
			screenshot()
		pressed = true

	if !Input.is_key_pressed(key) && pressed:
		pressed = false


func screenshot() -> void:
	# Take the screenshot, flip it and save it
	var image : Image = get_viewport().get_texture().get_data()
	image.flip_y()

	# Check for path existance
	checkPath()

	# Save the image
	var time : Dictionary = OS.get_datetime(true)

	# Date vars utility (padded with zeros)
	var year : String = "%04d" % time.get("year")
	var month : String = "%02d" % time.get("month")
	var day : String = "%02d" % time.get("day")
	var hour : String = "%02d" % time.get("hour")
	var minute : String = "%02d" % time.get("minute")
	var second : String = "%02d" % time.get("second")
	var unix : String = str(OS.get_unix_time())
	var index_string = "%02d" % index

	# Create file name
	var name = prefix + file_name.format({"Y": year, "M": month, "D": day, "h": hour, "m": minute, "s": second, "u": unix, "i": index_string}) + extension
	var error = image.save_png(path + "/" + name)

	# Print error if occur or the image name
	if error:
		print("ERROR : " + str(error))
	else:
		print("Frame captured: " + name)
		index += 1

	# Check for reach the index limit in burst mode
	if burst && index >= burst_number:
		timer.stop()


# Check for path and gdignore existence
func checkPath() -> void :
	var dir = Directory.new()
	var file = File.new()

	# Check directory existence
	if !dir.dir_exists(path):
		dir.make_dir(path)

	# Check file existence (avoid import screenshot in project)
	if create_gdignore && !file.file_exists(path + "/.gdignore"):
		file.open(path + "/.gdignore", File.WRITE)
		file.close()


# Return the string name of the key that toggle the screenshot
func getScreenshotKeyName() -> String:
	for i in range(KEYS.size()):
		if key == KEYS.values()[i]:
			return KEYS.keys()[i]

	return ""


# Return the int code of the key that toggle the screenshot
func getScreenshotKeyCode() -> int:
	return key