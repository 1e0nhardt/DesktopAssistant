extends Node

const music_file_directory = "C:/Users/hwk/Music/CloudMusic"

@onready var mucis_stream_player: AudioStreamPlayer = $MusicPlayer

var music_player: MusicPlayer
var _music_player_inited := false


func load_mp3(path: String):
    var file = FileAccess.open(path, FileAccess.READ)
    var sound = AudioStreamMP3.new()
    sound.data = file.get_buffer(file.get_length())
    return sound


class MusicPlayer:
    signal change_song(name: String)

    var files := []
    var song_names := []
    var _music_player: AudioStreamPlayer
    var play_position := 0.0
    var play_mode := "random"
    var current_index: int:
        set(value):
            current_index = value % len(files)
            _music_player.stream = load_stream(current_index)
            play()
            change_song.emit(song_names[current_index])
    var _playing := false:
        set(value):
            _playing = value
            if _playing:
                play_position = _music_player.get_playback_position()
                _music_player.stop()
            else:
                _music_player.play(play_position)

    func _init(path: String, player: AudioStreamPlayer):
        if not DirAccess.dir_exists_absolute(path):
            Logger.warn("%s is not a valid path!" % path)

        var all_files = DirAccess.get_files_at(path)
        for file in all_files:
            if file.ends_with(".mp3"):
                files.append(path + "/" + file)
                var song_name = file.substr(0, len(file) - 4)
                var song_info = song_name.split("-")
                song_info.reverse()
                song_name = "-".join(song_info)
                song_names.append(song_name)

        _music_player = player

        # Logger.debug("Song", files)
        current_index = 0

    func load_stream(index: int):
        var file = FileAccess.open(files[index], FileAccess.READ)
        var sound = AudioStreamMP3.new()
        sound.data = file.get_buffer(file.get_length())
        return sound

    func play():
        _music_player.play()

    func pause():
        _playing = not _playing

    func next():
        if play_mode == "random":
            current_index += randi_range(1, len(song_names))
        else:
            current_index += 1

    func prev():
        current_index -= 1

    func set_volume(slider_value: int):
        # (0, 100) -> (-20, 5)
        var db := slider_value * 0.25 - 20
        _music_player.volume_db = db


func init_music_player():
    if not _music_player_inited:
        music_player = MusicPlayer.new(music_file_directory, mucis_stream_player)
        _music_player_inited = true
