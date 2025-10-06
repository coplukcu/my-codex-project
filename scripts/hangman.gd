extends Control

@onready var word_label: Label = $MarginContainer/VBoxContainer/WordLabel
@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusLabel
@onready var attempts_label: Label = $MarginContainer/VBoxContainer/AttemptsLabel
@onready var guessed_label: Label = $MarginContainer/VBoxContainer/GuessedLabel
@onready var guess_input: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/GuessInput
@onready var guess_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/GuessButton

var words: PackedStringArray = [
    "GODOT",
    "OYUN",
    "KOD",
    "SCENE",
    "DUGUM",
    "TASARIM",
    "SCRIPT",
    "PIXEL",
    "MOTOR"
]

var rng := RandomNumberGenerator.new()
var secret_word := ""
var revealed_letters: PackedStringArray = []
var guessed_letters: PackedStringArray = []
var remaining_attempts := 6
var game_over := false
const ALLOWED_LETTERS := "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ"

func _ready() -> void:
    rng.randomize()
    reset_game()

func reset_game() -> void:
    secret_word = words[rng.randi_range(0, words.size() - 1)]
    revealed_letters = PackedStringArray()
    for i in range(secret_word.length()):
        revealed_letters.append("_")
    guessed_letters.clear()
    remaining_attempts = 6
    game_over = false
    status_label.text = "Harf girerek tahmin etmeye başla!"
    update_ui()
    enable_input(true)
    guess_input.clear()
    guess_input.grab_focus()

func update_ui() -> void:
    word_label.text = " ".join(revealed_letters)
    attempts_label.text = "Kalan deneme: %d" % remaining_attempts
    var guessed_text := guessed_letters.size() > 0 ? ", ".join(guessed_letters) : "(yok)"
    guessed_label.text = "Tahmin edilen harfler: %s" % guessed_text

func enable_input(enabled: bool) -> void:
    guess_input.editable = enabled
    guess_button.disabled = not enabled

func handle_guess(letter: String) -> void:
    if game_over:
        return

    var guess := letter.strip_edges().to_upper()
    if guess.is_empty():
        status_label.text = "Lütfen bir harf gir."
        return

    var char := guess.substr(0, 1)
    if not ALLOWED_LETTERS.contains(char):
        status_label.text = "Yalnızca harf tahmin edebilirsin."
        return

    if guessed_letters.has(char):
        status_label.text = "%s harfini zaten denedin." % char
        return

    guessed_letters.append(char)

    if secret_word.contains(char):
        for i in range(secret_word.length()):
            if secret_word.substr(i, 1) == char:
                revealed_letters[i] = char
        status_label.text = "%s harfi doğru!" % char
        if not revealed_letters.has("_"):
            status_label.text = "Tebrikler! Kelimeyi buldun: %s" % secret_word
            game_over = true
            enable_input(false)
    else:
        remaining_attempts -= 1
        status_label.text = "%s harfi yanlış." % char
        if remaining_attempts <= 0:
            status_label.text = "Oyunu kaybettin! Kelime: %s" % secret_word
            game_over = true
            enable_input(false)

    update_ui()

func _on_guess_button_pressed() -> void:
    handle_guess(guess_input.text)
    guess_input.clear()
    guess_input.grab_focus()

func _on_guess_input_text_submitted(new_text: String) -> void:
    handle_guess(new_text)
    guess_input.clear()
    guess_input.grab_focus()

func _on_restart_button_pressed() -> void:
    reset_game()
