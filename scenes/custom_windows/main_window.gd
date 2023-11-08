extends Control

@export var window_title: String
@export var show_status_bar: bool

@onready var title_label: Label = %WindowTitle
@onready var status_bar: PanelContainer = %StatusBar


func _ready():
    title_label.text = window_title
    status_bar.visible = show_status_bar


