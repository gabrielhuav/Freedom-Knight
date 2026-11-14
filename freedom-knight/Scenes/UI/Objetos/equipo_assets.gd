## Texture map for the four original pixel-art equipment sprites.
## These are gameplay assets, not QA screenshots.
extends RefCounted

const TEXTURAS = {
	"espada_hierro": preload("res://SpritesDelJuego/Equipamiento/espada_hierro.png"),
	"espada_sombras": preload("res://SpritesDelJuego/Equipamiento/espada_sombras.png"),
	"armadura_cuero": preload("res://SpritesDelJuego/Equipamiento/armadura_cuero.png"),
	"armadura_acero": preload("res://SpritesDelJuego/Equipamiento/armadura_acero.png"),
}


static func obtener_textura(item_id: String) -> Texture2D:
	return TEXTURAS.get(item_id, null) as Texture2D
