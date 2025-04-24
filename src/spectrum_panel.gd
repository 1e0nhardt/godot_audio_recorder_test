extends PanelContainer

var spectrum: AudioEffectSpectrumAnalyzerInstance


var playing := false:
    set(value):
        playing = value
        if playing:
            spectrum = AudioServer.get_bus_effect_instance(0, 0)
        else:
            spectrum = AudioServer.get_bus_effect_instance(1, 1)


func _ready():
    playing = false
