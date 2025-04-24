extends PanelContainer

const DISABLED_BUTTON_ALPHA = 0.7

@onready var title_panel: PanelContainer = $VBox/TitlePanel
@onready var close_button: TextureButton = %CloseButton
@onready var record_button: TextureButton = %RecordButton
@onready var play_button: TextureButton = %PlayButton
@onready var save_button: Button = %SaveButton
@onready var recording_playback: AudioStreamPlayer = $RecordingPlayback
@onready var spectrum_panel: PanelContainer = $VBox/MainHbox/SpectrumPanel

var effect: AudioEffectRecord
var recording: AudioStreamWAV
var path_last_saved: String = ""
var dragging: bool = false
var mouse_offset: Vector2


func _ready():
    close_button.pressed.connect(_on_close_button_pressed)
    record_button.toggled.connect(_on_record_button_toggled)
    play_button.toggled.connect(_on_play_button_toggled)
    save_button.pressed.connect(_on_save_button_pressed)
    title_panel.gui_input.connect(_on_title_panel_gui_input)

    effect = AudioServer.get_bus_effect(1, 0)

    play_button.modulate.a = DISABLED_BUTTON_ALPHA
    save_button.modulate.a = DISABLED_BUTTON_ALPHA
    play_button.disabled = true
    save_button.disabled = true


func _on_title_panel_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            dragging = true
            mouse_offset = get_global_mouse_position()
        elif not event.pressed:
            dragging = false


func _process(_delta: float) -> void:
    if dragging:
        var mouse_pos = get_global_mouse_position()
        get_window().position += Vector2i(mouse_pos - mouse_offset)


func _on_close_button_pressed():
    get_tree().quit()


func _on_record_button_toggled(_toggled_on: bool):
    if effect.is_recording_active():
        print("Recording stopped")
        recording = effect.get_recording()
        recording_playback.stream = recording
        effect.set_recording_active(false)

        play_button.disabled = false
        play_button.modulate.a = 1
        save_button.disabled = false
        save_button.modulate.a = 1
    else:
        effect.set_recording_active(true)
        recording_playback.stop()
        spectrum_panel.playing = false
        print("Recording started")


func _on_play_button_toggled(toggled_on: bool):
    spectrum_panel.playing = toggled_on
    if toggled_on:
        recording_playback.play()
    else:
        recording_playback.stop()


func _on_save_button_pressed():
    var l_dialog = FileDialog.new()
    l_dialog.title = "Save recording"
    l_dialog.mode = FileDialog.FILE_MODE_SAVE_FILE
    l_dialog.use_native_dialog = true
    l_dialog.access = FileDialog.ACCESS_FILESYSTEM
    l_dialog.filters = ["*.wav"]
    l_dialog.file_selected.connect(_on_file_selected)
    l_dialog.current_dir = path_last_saved
    add_child(l_dialog)
    l_dialog.popup_centered()


func _on_file_selected(a_file: String):
    path_last_saved = a_file.get_base_dir()
    if recording:
        recording.save_to_wav(a_file)
