/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/stack_objects.dmi'
	amount = 8
	max_amount = 8
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE
	max_integrity = 40
	novariants = FALSE
	var/heal_brute = 0
	var/heal_burn = 0
	var/stop_bleeding = 0
	var/self_delay = 20
	var/repeating = 0

/obj/item/stack/medical/attack(mob/living/M, mob/user)
	. = ..()
	try_heal(M,user)

/obj/item/stack/medical/proc/try_heal(mob/living/M, mob/user)

	use(1)

	if(!iscarbon(M) && !isanimal(M))
		to_chat(user, "<span class='danger'>You don't know how to apply \the [src] to [M]!</span>")
		return 1

	var/obj/item/bodypart/affecting
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		affecting = C.get_bodypart(check_zone(user.zone_selected))
		if(!affecting) //Missing limb?
			to_chat(user, "<span class='warning'>[C] doesn't have \a [parse_zone(user.zone_selected)]!</span>")
			return
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(stop_bleeding)
				if(H.bleedsuppress)
					to_chat(user, "<span class='warning'>[H]'s bleeding is already bandaged!</span>")
					return
				else if(!H.bleed_rate)
					to_chat(user, "<span class='warning'>[H] isn't bleeding!</span>")
					return


	if(isliving(M))
		if(!M.can_inject(user, 1))
			return

	if(user)
		if (M != user)
			if (isanimal(M))
				var/mob/living/simple_animal/critter = M
				if (!(critter.healable))
					to_chat(user, "<span class='notice'> You cannot use [src] on [M]!</span>")
					return
				else if (critter.health == critter.maxHealth)
					to_chat(user, "<span class='notice'> [M] is at full health.</span>")
					return
				else if(src.heal_brute < 1)
					to_chat(user, "<span class='notice'> [src] won't help [M] at all.</span>")
					return
			user.visible_message("<span class='green'>[user] applies [src] on [M].</span>", "<span class='green'>You apply [src] on [M].</span>")
		else
			var/t_himself = "itself"
			if(user.gender == MALE)
				t_himself = "himself"
			else if(user.gender == FEMALE)
				t_himself = "herself"
			user.visible_message("<span class='notice'>[user] starts to apply [src] on [t_himself]...</span>", "<span class='notice'>You begin applying [src] on yourself...</span>")
			if(!do_mob(user, M, self_delay, extra_checks=CALLBACK(M, /mob/living/proc/can_inject, user, TRUE)))
				return
			user.visible_message("<span class='green'>[user] applies [src] on [t_himself].</span>", "<span class='green'>You apply [src] on yourself.</span>")


	if(iscarbon(M))
		var/mob/living/carbon/C = M
		affecting = C.get_bodypart(check_zone(user.zone_selected))
		if(!affecting) //Missing limb?
			to_chat(user, "<span class='warning'>[C] doesn't have \a [parse_zone(user.zone_selected)]!</span>")
			return
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(stop_bleeding)
				if(!H.bleedsuppress) //so you can't stack bleed suppression
					H.suppress_bloodloss(stop_bleeding)
		if(affecting.status == BODYPART_ORGANIC) //Limb must be organic to be healed - RR
			if(affecting.heal_damage(heal_brute, heal_burn))
				C.update_damage_overlays()
		else
			to_chat(user, "<span class='notice'>Medicine won't work on a robotic limb!</span>")
		if(repeating && amount > 0)
			try_heal(M,user)
	else
		M.heal_bodypart_damage((src.heal_brute/2), (src.heal_burn/2))

/obj/item/stack/medical/bruise_pack
	name = "bruise pack"
	singular_name = "bruise pack"
	desc = "A therapeutic gel pack and bandages designed to treat blunt-force trauma."
	icon_state = "brutepack"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	heal_brute = 30
	self_delay = 20
	grind_results = list("styptic_powder" = 10)

/obj/item/stack/medical/bruise_pack/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is bludgeoning [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/stack/medical/gauze
	name = "medical gauze"
	desc = "A roll of elastic cloth that is extremely effective at stopping bleeding, but does not heal wounds."
	gender = PLURAL
	singular_name = "medical gauze"
	icon_state = "gauze"
	stop_bleeding = 1800
	self_delay = 20
	max_amount = 12


/obj/item/stack/medical/gauze/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WIRECUTTER || I.is_sharp())
		if(get_amount() < 2)
			to_chat(user, "<span class='warning'>You need at least two gauzes to do this!</span>")
			return
		new /obj/item/stack/sheet/cloth(user.drop_location())
		user.visible_message("[user] cuts [src] into pieces of cloth with [I].", \
					 "<span class='notice'>You cut [src] into pieces of cloth with [I].</span>", \
					 "<span class='italics'>You hear cutting.</span>")
		use(2)
	else
		return ..()

/obj/item/stack/medical/gauze/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] begins tightening \the [src] around [user.p_their()] neck! It looks like [user.p_they()] forgot how to use medical supplies!</span>")
	return OXYLOSS

/obj/item/stack/medical/gauze/improvised
	name = "improvised gauze"
	singular_name = "improvised gauze"
	desc = "A roll of cloth roughly cut from something that can stop bleeding, but does not heal wounds."
	stop_bleeding = 900

/obj/item/stack/medical/gauze/cyborg
	materials = list()
	is_cyborg = 1
	cost = 250

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burn wounds."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	heal_burn = 30
	self_delay = 20
	grind_results = list("silver_sulfadiazine" = 10)

/obj/item/stack/medical/ointment/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is squeezing \the [src] into [user.p_their()] mouth! [user.p_do(TRUE)]n't [user.p_they()] know that stuff is toxic?</span>")
	return TOXLOSS

/obj/item/stack/medical/suture
	name = "suture pack"
	singular_name = "suture"
	desc = "A surgical needle with a length of a sterile thread designed to treat and stitch surface blunt-force trauma for further treatment."
	icon_state = "suture"
	amount = 14
	max_amount = 14
	repeating = 1
	heal_brute = 10
	self_delay = 10
	grind_results = null

/obj/item/stack/medical/mesh
	name = "sterile mesh pack"
	singular_name = "sterile mesh"
	desc = "A bandage-like material meant to be wrapped around first-to-second degree burns for further treatment."
	icon_state = "mesh"
	lefthand_file = null
	righthand_file = null
	amount = 14
	max_amount = 14
	repeating = 1
	heal_burn = 10
	self_delay = 10
	grind_results = null

/obj/item/stack/medical/trauma_kit
	name = "advanced trauma kit"
	desc = "An assortment of various highly advanced styptic membranes meant to completely treat any sort of heavy wounds."
	singular_name = "trauma kit"
	icon_state = "traumakit"
	lefthand_file = null
	righthand_file = null
	amount = 6
	max_amount = 6
	heal_brute = 45
	self_delay = 35
	grind_results = null

/obj/item/stack/medical/burn_kit
	name = "advanced burn kit"
	desc = "An assortment of various highly advanced aseptic membranes meant to completely treat any sort of heavy burns."
	singular_name = "burn kit"
	icon_state = "burnkit"
	lefthand_file = null
	righthand_file = null
	amount = 6
	max_amount = 6
	heal_burn = 45
	self_delay = 35
	grind_results = null
