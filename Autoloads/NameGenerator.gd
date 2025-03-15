extends Node2D



var rng = RandomNumberGenerator.new()


var nouns = []
var adjectives = []
var names = []
var verbs = []


var multi = []
var places = []
var people = []
var dungeons = []
var concepts = []


func generate_dungeon_name():
	
	randomize()
	name_gen_base()
	
	var rand = rng.randi_range(0,2)
	var dungeon_name = ""
	
	if rand == 0:
		return str( dungeons[0].capitalize() + " Of " + concepts[0].capitalize())
		
	elif rand == 1:
		return str( dungeons[0].capitalize() + " Of " + names[0].capitalize())
		
	elif rand == 2:
		return str("The " + adjectives[0].capitalize() + " " + dungeons[0].capitalize())
		
		


func generate_name():
	
	# Generate the wordlists for the generator
	randomize()
	name_gen_base()
	
	#############################################################################
	
	
	
	var array2 = [1,2,3,4,5,6]
	var num2 = array2[randi() % array2.size()-1]
	
	var adj = adjectives[0]
	adj = adj.capitalize()
	
	var name1 = names[0]
	name1 = name1.capitalize()
	
	nouns[0] = nouns[0].capitalize()
	nouns[1] = nouns[1].capitalize()
	
	
	people[0] = people[0].capitalize()
	concepts[0] = concepts[0].capitalize()
	places[0] = places[0].capitalize()
	
	# THE adjective something!
	if num2 == 1:
		return str("The " + adj + " " + name1)
	if num2 == 2:	
		return str("The " + adj + " " + nouns[0])
		
	# THE NOUN Of something!
	if num2 == 3:
		return str( nouns[0] + " Of The " + people[0])
	if num2 == 4:
		return str( places[0] + " Of " + concepts[0])
		
	# NAME The something!
	if num2 == 5:
		return str( name1 + " The " + adj)
		
	if num2 == 6:
		return str("The " + adj + " " + multi[0])
	


	return str("  ERROR")






func name_gen_base():
	
	
	
	
	#########################################################################
	
	multi = ["pillars","wastes","echoes","lands","caves","caverns","reaches",
	"heights","halls","doors","stones","catacombs"]
	
	places = ["sanctum","city","hamlet","mountain","grove","warren","tunnel","court",
	"keep","yard","haven","garden","ossuary"]
	
	people = ["Slaver","King","Queen","Duchess","Trader","Soldier",
	"Wizard","Acolyte","Beggar","Liar","Knight"]
	
	dungeons = ["dungeon","lair","domain","coven","bastion","delve"]
	
	var places_2 = ["vestibule","rampart","stockade","vault","crypt","estuary",
	"delta","span","way","cataract","deep","tomb","tunnel","fortress"]
	
	concepts = ["eternity","wisdom","emptiness","atrocity","truth","honesty","memory",
	"folly","mania","shadows"]
	
	
	nouns += places
	places += places_2
	#nouns += people
	nouns += dungeons
	nouns += multi
	nouns += places_2
	
	nouns.shuffle()
	places.shuffle()
	people.shuffle()
	dungeons.shuffle()
	multi.shuffle()
	concepts.shuffle()
	
	#########################################################################
	
	
	
	var colors = ["red","blue","Gold","Vermillion","Azure","Amber","Purple","ashen","ivory",
	"white","grey","black"]
	
	var adj_menacing = ["Forgotten","Lost","Unspeakable","Furious","Bestial","Venomous","Weeping"]
	
	var adj_ing_menacing = ["Blighting","Searing","Conquering","Slaying","Vanishing"]
	
	var moody = ["distant","lonely","sacred","echoing","vengeful","twisting","whispering","fabled",
	"baleful","tempered","defiant","unreal"]
	
	adjectives += colors
	adjectives += adj_menacing
	adjectives += adj_ing_menacing
	adjectives += moody
	
	adjectives.shuffle()
	
	#########################################################################
	
	
	
	
	var names_1 = ["Almol","Gont","Mondor","Aran","Oshum","Gorb"]
	
	var names_2 = ["Silmol","Shalrak","Volana","Ryugon","Naral","Ishaan","Rakush","Endemore","Uilim"]
	
	#var names_2 = ["","","","","","","","","","","",""]
	#var names_3 = ["","","","","","","","","","","",""]
	#var names_2 = ["","","","","","","","","","","",""]
	
	
	
	names += names_1
	names += names_2
	
	
	names.shuffle()
	#########################################################################
	
	
	return [nouns,adjectives,names]
	
	
	
	
