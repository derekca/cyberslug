;!/bin/sh
; AUTHOR : Derek Caetano-Anolles
; EDITED : 2009.12.09
; SCRIPT : PLEUROBRANCHAEA BEHAVIOR SIMULATION
; DESCR. : Netlogo simulation demonstrating sea slug predation, orientation, and mating behavior.

;;_________________________________________________________________________________________________________________
;;                                          ** VARIABLES **
;;_________________________________________________________________________________________________________________

globals [max-pleuro-who-number ;maximum number of pleuros that have existed, increases when pleuro is born (used for identitification)
         list-hermi            ;list of all the satiation values at the time of food-consumption (for finding mean, std deviation, etc) 
         list-flab
         list-faux
         list-pleuro
        ] 

;organism breeds
breed [pleuros pleuro]
breed [pleuroeggs pleuroegg]
breed [pleurolarvae pleurolarva]

breed [probos proboscis]
breed [emotions emotion]

breed [flabs flab]
breed [hermis hermi]
breed [fauxhermis fauxhermi]

breed [particulates particulate]
breed [particulateswimmers particulateswimmer]

pleuroeggs-own   [egg-timer]
pleurolarvae-own [larva-timer]
emotions-own     [emotion-timer]
particulates-own [x-cor y-cor z-cor]

patches-own [odor-flab
             odor-hermi
             odor-bet
             odor-pleuros
             odor-aversive
            ]
probos-own  [parent
             phase
             probos-size
            ]

;pleuros information
pleuros-own [sns-flab-left      ;flab sensors
             sns-flab-right
             sns-hermi-left     ;hermi sensors
             sns-hermi-right
             sns-bet-left       ;betaine sensors
             sns-bet-right             
             chemosns-NW        ;aversive factor sensors (on skin of pleuros)
             chemosns-SW
             chemosns-NE
             chemosns-SE
             
             snshermi           ;hermi sensor, for computation
             snsflab            ;flab sensor, for computation
             snspleuros         ;pleuros sensor, for computation
             snsaversive        ;aversive sensor, for computation
             
             energy             ;increases with food eaten, decreases with movement
             satiation          ;proportional to energy
             
             digest-timer       ;tells pleuros how long it takes to eat & digest food
             vomit-timer        ;tells pleuros how long it takes to wait & spit out 'gross' food
             fear-timer         ;tells pleuros how long it takes to run away from predator
             mate-timer         ;when active, tells pleuros to look for a mate, and how long it takes to mate
             egglay-timer       ;tells pleuros how long it takes to lay eggs
             death-timer        ;once pleuros increases to max size, it will countdown to its death

             app                ;sensory path carrying Appetitive info
             noc                ;sensory path carrying Nociceptive info
             fn                 ;represents Feeding Network state
             h1                 ;learning variable for Hermi, associates appetitiveness, partly a function of satiation 
             f1                 ;learning variable for Flab, associates nociception, partly a function of satiation
             
             action             ;movement related variables
             speed              ;  " "     " "     " "
             turn-direction     ;  " "     " "     " "
             turn-angle         ;  " "     " "     " "
             turn-threshold     ;  " "     " "     " "
             
             parent-who-number
            ]





;;_________________________________________________________________________________________________________________
;;                                          ** SET-UP **
;;_________________________________________________________________________________________________________________
;;sets the state of the simulation at the start of the program & when it is reset.

to startup
  setup
end

to setup
  clear-all
  
  ;set up beginning values of all global variables
  set max-pleuro-who-number 1 ;the first pleuro to be born will have an ID # of 1

  set list-hermi  []
  set list-flab   []
  set list-faux   []
  set list-pleuro []
  output-introduction
  
  setup-initialize-organisms
  setup-initialize-odors
  
end

to output-introduction
;prints the introduction into the Command Console
  print " "
  print "------------------------------------------------------------------"
  print "PLEUROBRANCHAEA SLUG BEHAVIOR SIMULATION"
  print "New simulation set up with: "
    type "-- "
    type pleuro-pop type " slugs, "
    type hermi-pop  type " hermisenda, "
    type flab-pop   type " flabellina, and "
    type faux-pop   type " faux-hermisenda."
  print " "
  ifelse (growth)
    [print "-- Growth, mating, and death of slugs ENABLED."]
    [print "-- Growth, mating, and death of slugs DISABLED."]
  print "------------------------------------------------------------------"
  print "Information on subject slug: (Emotion | Food Eaten | Satiation State)"
end


;;-----------------------------------------------------------
;;           SETUP - Initialize Organisms
;;-----------------------------------------------------------
;;summon slugs, food, etc. onto the field

to setup-initialize-organisms

  repeat pleuro-pop
    [setup-initialize-pleuro] ;pleurobranchaea summoning program, creates the number of pleuro from pleuro-population slider
  setup-initialize-flab       ;flabellina summoning program 
  setup-initialize-hermi      ;hermisenda summoning program
  setup-initialize-fauxhermi  ;faux-hermisenda summoning program
  
  setup-initialize-particulates
  
end

to setup-initialize-pleuro
  ;PLEUROBRANCHAEA (Population Initialization)
  ;brown slug, brown odor
  create-pleuros 1 ;creates 1 pleuro
  [
    ;give pleuro random location & size
    setxy random-xcor random-ycor
    set size 5 + random 3
    setup-initialize-pleuro-values
  ]
end

to setup-initialize-pleuro-values
  set heading (random 360)
  
  ;give pleuro form
  set shape "pleuro" 
  set color orange - 2
  
  ;give pleuro starting values
  set snshermi 1
  set snsflab 1
  set snspleuros 1
  set snsaversive 1
  
  set speed 0.15
  set energy 1
  set satiation 0.215
  set turn-threshold 0
  set digest-timer 0
  set mate-timer 0
  set death-timer -1 ;this means it won't die. when the time is above 0 it will begin to die
  
  set app 0
  set noc 0
  set fn 0
  set h1 0
  set f1 0

  ;pleuro creates its proboscis (on top of itself)
  hatch-probos 1
  [
    set shape "probos"
    set parent myself
    set size 0.5 ;the initial size does not matter - the update-proboscis function sets it relative to parent's size
  ]
  
  set parent-who-number (max-pleuro-who-number) ;the parent-who-number and the node-who-number identify which node belongs to which pleuro (starts at 0)
  set max-pleuro-who-number (max-pleuro-who-number + 1) ;increase the maximum who number [global] to be used for pleuro turn taking tasks
end

to setup-initialize-flab
  ;FLABELLINA (Population Initialization)
  ;red orb, red odor
  create-flabs flab-pop    ;creates number of flabs from flabellina-population slider
  [
    set shape "cylinder"
    set size 0.75
    set color red + 1
    setxy random-xcor random-ycor
  ]
end

to setup-initialize-hermi
  ;HERMISENDA (Population Initialization)
  ;green orb, green odor
  create-hermis hermi-pop    ;creates number of hermis from hermisenda-population slider
  [
    set shape "cylinder"
    set size 0.75
    set color green + 2
    setxy random-xcor random-ycor
  ]
end

to setup-initialize-fauxhermi
  ;FAUX-HERMISENDA (Population Initialization)
  ;green orb, red odor
  ;faux-hermi is an hermisenda species that mimics flabellina odor (batesian mimicry)
  create-fauxhermis faux-pop    ;creates number of flabs from faux-hermisenda-population slider
  [
    set shape "cylinder"
    set size 0.75
    set color green + 2
    setxy random-xcor random-ycor
  ]
end

to setup-initialize-particulates
;particulates are part of the visual-effects that make it appear as if the simulation
;takes place under water, and only takes place if the "effects" toggle is activated.
  if (effects)
  [
    create-particulates 100
    [
      set shape "probos"
      set size 0.5 + 0.01 * random 8
      set color gray - 2 - random 3
      setxy random-xcor random-ycor
    ]
    ask particulates
    [
      set x-cor random-float 100 - 50
      set z-cor random-float 100 - 50
      set y-cor 0
    ]
    create-particulateswimmers 50
    [
      set shape "probos"
      set size 0.5 + 0.01 * random 8
      set color blue - 2 - random 3
      setxy random-xcor random-ycor
    ]
  ]
end

;;-----------------------------------------------------------
;;           SETUP - Initialize Odors
;;-----------------------------------------------------------
;;summons initial odor states onto the field

to setup-initialize-odors
  repeat 10    ;repeat so that the odor starts out already diffused
  [
    ;add odors for each species
    ask flabs [
      set odor-flab 0.5
      set odor-bet 0.5
      ]
    ask hermis [
      set odor-hermi 0.5
      set odor-bet 0.5
      ]
    ask fauxhermis [
      set odor-flab 0.5
      set odor-bet 0.5
      ]
    ask pleuros [
      set odor-pleuros 0.1
      set odor-aversive (size)
      ]
    
    ;diffuse odors for each species
    diffuse odor-flab 0.5
    diffuse odor-hermi 0.5
    diffuse odor-bet 0.5
  ]
  
  ;call recolor program to add colors onto all patches relative to odor state
  ask patches [odor-recolor-patches]

end


;;_________________________________________________________________________________________________________________
;;                                          ** GO **
;;_________________________________________________________________________________________________________________
;;the main simulation, sets the state of all turtles & patches per tick

to go

  user-click-interactions
  odor-mechanics
  
  pleuros-behavior
  food-behavior
  tempturtle-behavior
  
  update-plots
  
  tick
end

;;-----------------------------------------------------------
;;           GO - User Interactions
;;-----------------------------------------------------------
;;what the user is allowed to do while simulation runs

to user-click-interactions
;what happens when the user clicks on the screen
;requires selection from Pull-Down Menu ('click-interaction') to choose action
  
  if mouse-down?
  [
    ;DRAG OBJECTS
    ;allows user to drag objects around environment
    if click-interaction = "Drag Objects"
    [
      ask pleuros    [ if distancexy mouse-xcor mouse-ycor < 4 [setxy mouse-xcor mouse-ycor] ]
      ask flabs      [ if distancexy mouse-xcor mouse-ycor < 4 [setxy mouse-xcor mouse-ycor] ]
      ask hermis     [ if distancexy mouse-xcor mouse-ycor < 4 [setxy mouse-xcor mouse-ycor] ]
      ask fauxhermis [ if distancexy mouse-xcor mouse-ycor < 4 [setxy mouse-xcor mouse-ycor] ]
      ask pleuroeggs [ if distancexy mouse-xcor mouse-ycor < 4 [setxy mouse-xcor mouse-ycor] ]
    ]
    ;PLACE EGGS
    ;allows user to drop some eggs in the environment
    if click-interaction = "Place Eggs"
    [
      create-pleuroeggs (1 + random 2)
      [
        setxy mouse-xcor mouse-ycor
        set shape "target"
        set color orange - 2
        set size 1.5
        set egg-timer 10 + random 50
      ]
    ]
    ;KILL SLUG
    ;allows user to give the touch of death to a slug
    if click-interaction = "Kill Slug"
    [
      ask pleuros
      [
        if (distancexy mouse-xcor mouse-ycor < 5)
          [set death-timer 2]
      ]
    ]
    ;GROW SLUG
    ;allows user to increase size of slug by touching it
    if click-interaction = "Grow Slug"
    [
      ask pleuros
      [
        if (distancexy mouse-xcor mouse-ycor < 5)
          [set digest-timer 30]
      ]
    ]
    ;ODOR - GREEN HERMIS
    ;allows user to create stream of hermis scent in environment
    if click-interaction = "Odor - Green Hermis"
    [
      repeat 1 [
        ask patch mouse-xcor mouse-ycor [
          set odor-hermi 2
          set odor-bet   2
        ]
      ]
    ]
    ;ODOR - RED FLAB
    ;allows user to create stream of flab scent in environment
    if click-interaction = "Odor - Red Flab"
    [
      repeat 1 [
        ask patch mouse-xcor mouse-ycor [
          set odor-flab  2
          set odor-bet   2
        ]
      ]
    ]
    ;ODOR - BROWN PLEUROS
    ;allows user to create stream of pleuros scent in environment
    if click-interaction = "Odor - Brown Pleuros"
    [
      repeat 1 [
        ask patch mouse-xcor mouse-ycor [
          set odor-pleuros 2
          set odor-bet   2
        ]
      ]
    ]
  ]
end


;;-----------------------------------------------------------
;;           GO - Odor Mechanics
;;-----------------------------------------------------------
;;odor creation & diffusion throughout the world

to odor-mechanics
  
  ;DEPOSIT ODORS
  ask flabs [
    set odor-flab 0.5
    set odor-bet 0.5
    ]
  ask hermis [
    set odor-hermi 0.5
    set odor-bet 0.5
    ]
  ask fauxhermis [
    set odor-flab 0.5
    set odor-bet 0.5
    ]
  ask-concurrent pleuroeggs [
    set odor-pleuros 0.10
    set odor-bet 0.10
    ]
  ask-concurrent pleuros [
    set odor-pleuros size / 20
    set odor-bet 0.10
    let aversivevalue 2 * size
    
    let angle-sns 0      ;creates aversive odor 10 times, every 36 degrees (all around pleuros)
    repeat 36 [
      ask patch-left-and-ahead angle-sns (0.3 * size)  [set odor-aversive (aversivevalue)]
      set angle-sns (angle-sns + 10)
      ]
    ]
    
  ;DIFFUSE ODORS
  diffuse odor-flab 0.5
  diffuse odor-hermi 0.5
  diffuse odor-bet 0.5
  diffuse odor-pleuros 0.80
  
  ;EVAPORATE ODORS
  ask patches
  [
    set odor-flab 0.98 * odor-flab
    set odor-hermi 0.98 * odor-hermi
    set odor-bet 0.98 * odor-bet
    set odor-pleuros 0.98 * odor-pleuros
    set odor-aversive 0.50 * odor-aversive
    odor-recolor-patches
  ]

end

to odor-recolor-patches
;RECOLOR PATCHES DEPENDING ON ODOR STRENGTH
  
  ;This code does not work 100% -- flab-color masks plurb-color when they overlap.
  ;However, this is only a visual problem, the odor-values are not affected.
  ifelse (odor-flab > odor-hermi)
    [set pcolor scale-color red odor-flab 0 1]
    [ifelse (odor-hermi > odor-pleuros)
      [set pcolor scale-color green odor-hermi 0 1]
      [set pcolor scale-color orange odor-pleuros 0 1]
    ]
    
  ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  ;set the below code active only if you want to see the aversive factor produced by the pleuros
  ;set pcolor scale-color blue odor-aversive 0 1
  ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  
end






;;_________________________________________________________________________________________________________________
;;_________________________________________________________________________________________________________________
;;                                          ** PLEUROS BEHAVIOR **
;;_________________________________________________________________________________________________________________
;;_________________________________________________________________________________________________________________
;;everything that pleuros does goes on in this section.

to pleuros-behavior
  update-proboscis          ;update proboscis movement
  ask pleuros
  [
    update-sensors            ;update pleuro's senses

    pleuros-movement          ;pleuros decides how to act
    pleuros-predation         ;pleuros will eat food that has come near proboscis
    
    ;energy loss with time
    set energy energy - 0.001
    
    ;kill slug if it has no energy
    if (energy < 0 AND death-timer < 0) [set death-timer 100]
    pleuros-deathcountdown    ;pleuros will countdown to its death once its countdown timer is activated

    ;satiation state couples to energy
    set satiation (1 + 15 * exp (- energy)) ^ -1
  ]
  
end

;;-----------------------------------------------------------
;;           Pleuros Behavior - SENSING
;;-----------------------------------------------------------
;this updates the pleuros on its surroundings

to update-sensors
  
  ;FLABELLINA SENSOR UPDATE
  let odor-flab-left [odor-flab] of patch-left-and-ahead 40 (0.4 * size)
  ifelse odor-flab-left > 1e-7 
    [set sns-flab-left 7 + (log odor-flab-left 10)] 
    [set sns-flab-left 0]
  let odor-flab-right [odor-flab] of patch-right-and-ahead 40 (0.4 * size)
  ifelse odor-flab-right > 1e-7 
    [set sns-flab-right 7 + (log odor-flab-right 10)] 
    [set sns-flab-right 0]
  
  ;FAUX/HERMISENDA SENSOR UPDATES
  let odor-hermi-left [odor-hermi] of patch-left-and-ahead 40 (0.4 * size)
  ifelse odor-hermi-left > 1e-7 
    [set sns-hermi-left 7 + (log odor-hermi-left 10)]
    [set sns-hermi-left 0]
  let odor-hermi-right [odor-hermi] of patch-right-and-ahead 40 (0.4 * size)
  ifelse odor-hermi-right > 1e-7 
    [set sns-hermi-right 7 + (log odor-hermi-right 10)]
    [set sns-hermi-right 0]
  
  ;BETAINE SENSOR UPDATES 
  let odor-bet-left [odor-bet] of patch-left-and-ahead 40 (0.4 * size)
  ifelse odor-bet-left > 1e-7 
    [set sns-bet-left 7 + (log odor-bet-left 10)]
    [set sns-bet-left 0]
  let odor-bet-right [odor-bet] of patch-right-and-ahead 40 (0.4 * size)
  ifelse odor-bet-right > 1e-7 
    [set sns-bet-right 7 + (log odor-bet-right 10)] 
    [set sns-bet-right 0]
  
  ;CONSPECIFIC PLEUROS SENSOR UPDATE
  set chemosns-NW 0
  set chemosns-SW 0
  set chemosns-NE 0
  set chemosns-SE 0
  
  let rotate 0
  repeat 30
  [
    let odor-aversive-NW [odor-aversive] of patch-left-and-ahead (0 + rotate) (0.3 * size)
    if (odor-aversive-NW > size)
      [set chemosns-NW odor-aversive-NW - size]
      
    let odor-aversive-SW [odor-aversive] of patch-left-and-ahead (90 + rotate) (0.3 * size)
    if (odor-aversive-SW > size)
      [set chemosns-SW odor-aversive-SW - size]

    let odor-aversive-NE [odor-aversive] of patch-right-and-ahead (0 + rotate) (0.3 * size)
    if (odor-aversive-NE > size)
      [set chemosns-NE odor-aversive-NE - size]

    let odor-aversive-SE [odor-aversive] of patch-right-and-ahead (90 + rotate) (0.3 * size)
    if (odor-aversive-SE > size)
      [set chemosns-SE odor-aversive-SE - size]

    set rotate rotate + 3
  ]
end

;;-----------------------------------------------------------
;;           Pleuros Behavior - MOVING
;;-----------------------------------------------------------
;pleuros movement decisions... will it wander/approach/avoid/mate?

to pleuros-movement

  pleuros-movement-determination        ;determine the sns values to be used in approach calculations
  pleuros-movement-orient               ;orienting & avoidance behavior
  
  rt turn-angle                         ;after running getting values for angle/speed, pleuros rotates
  
  ifelse (vomit-timer = 0)
    [
      ifelse (digest-timer = 0)
        [fd speed]                          ;if pleuros is not digesting, and not vomiting, it will move at the 'speed' setting
        [pleuros-predation-digest fd speed] ;if its digest-timer is active, it will run through the digestion program, & THEN move
    ]
    [pleuros-predation-vomit fd speed]      ;if its vomit-timer is active, it will run through the vomit program, & THEN move
    
  pleuros-movement-conspecific          ;movement of pleuros when near other slug
  
end


to pleuros-movement-determination
;DETERMINE SNS VALUES (TO DECIDE HOW TO ACT)
  let avg-sns-hermi (sns-hermi-left + sns-hermi-right ) / 2
  let avg-sns-bet (sns-bet-left + sns-bet-right ) / 2
  let avg-sns-flab (sns-flab-left + sns-flab-right ) / 2 ;- (1 / (1 + exp ( 4 - avg-sns-hermi)))
                                                         ;(1/(1+e^(-x+3.5)) tweek this? hermi inhibits flab.
  set avg-sns-hermi avg-sns-hermi - snsflab * 1 / (20 * exp (20 * snsflab));(1 / (1 + exp ( 4 - avg-sns-flab))))

  set snshermi avg-sns-hermi 
  set snsflab avg-sns-flab - snshermi  * 1 / (20 * exp (20 * snshermi));  do the subtraction...
  
  ;set appetence & nociception, feeding network state to control turn decisions 
  set app (avg-sns-bet / (30 * satiation)) + snshermi * h1 / (1.5 * satiation)
  set noc (avg-sns-bet * 0.15 + snsflab * f1)   ;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<THIS IS THE OLD (F1) MODEL FOR NOC
  
  set fn app - noc
end


to pleuros-movement-orient
;ORIENTATION ANGLE & SPEED FOR ORIENTING

  let avg-sns-bet (sns-bet-left + sns-bet-right ) / 2
  
  ifelse (avg-sns-bet > 2.5 + (satiation / 2 ))
  [
    set action "orient"
    set turn-direction (10 / (1 + exp (- 20 * fn)) - 1); the 20 just slurs the curve
    set turn-angle turn-direction * (2 * app) * ( -0.5 + (1 / (1 + exp (3 * (sns-bet-left - sns-bet-right) ))))
    set speed ( speed - ( speed / 12) + 0.04 ) ;this is the rate for APPROACH/AVOIDANCE
    if (avg-sns-bet > 0.75)
    [
      set action "slow-orient"
      set turn-direction (10 / (1 + exp (- 20 * fn)) - 1); the 20 just slurs the curve
      set turn-angle turn-direction * (2 * app) * ( -0.5 + (1 / (1 + exp (3 * (sns-bet-left - sns-bet-right) ))))
      set speed ( speed - ( speed / 12) + 0.01) ;this is the rate for APPROACH/AVOIDANCE very near the object
    ]
  ]
  [
    ;DEFAULT behavior is wandering
    pleuros-movement-wander
  ]
  
end


to pleuros-movement-wander
;WANDER - default actions
  set action "wander"
  set speed 0.15 + app ;(was originally 0.075 + app)
  set turn-angle -1 + random-float 2
end


to pleuros-movement-conspecific
  if ((chemosns-NW > 0) OR (chemosns-SW > 0) OR (chemosns-NE > 0) OR (chemosns-SE > 0))
  [
    ifelse (size > 7)
      [ifelse (growth) [set mate-timer 10][set fear-timer 3] ] ; allow egg laying if the 'growth' switch is activated]
      [set fear-timer 3]
  ]
    
  ;CONSPECIFIC BEHAVIORS: MEETING SOMEONE BIGGER THAN YOU
  if (fear-timer != 0)
  [
    if (chemosns-NW > 0)
      [set speed (0) rt 20]
    if (chemosns-NE > 0)
      [set speed (0) rt -20]
    if (chemosns-SE > 0)
      [set speed (speed + 0.5) rt -5]
    if (chemosns-SW > 0)
      [set speed (speed + 0.5) rt 5]
    
    ;;pleuros flashes color briefly because it is scared
    ifelse (fear-timer < 2)
      [set color orange - 2]
      [set color blue]
    
    set fear-timer (fear-timer - 1)        ;this lowers the fear timer
  ]
  
  ;CONSPECIFIC BEHAVIORS: MEETING SOMEONE SMALLER THAN YOU, FOR MATING
  if (mate-timer != 0)
  [
    set speed (speed - speed / 5)
    rt -15 + random 25
    let matingpartner other (turtle-set pleuros)in-cone (.6 * size) 360
    if any?(matingpartner)
    [
      ask matingpartner [set mate-timer 10] ; this 'impregnates' the other pleuros so it also lays eggs
    ]
    
    hatch-emotions 1
    [
      set size 4
      set shape "heart"
      set color pink
      set emotion-timer 50
    ]
    if (mate-timer = 1)
    [
      egg-behavior
      if (parent-who-number = 1) [print "<3 Slug mated with another slug, and laid eggs."] ;print that pleuro 0 mated
    ]
    set mate-timer (mate-timer - 1)
  ]
  
  ;CONSPECIFIC BEHAVIORS: LAYING EGGS (this happens when mate-timer is active)
  if (egglay-timer != 0)
  [
    set size (size - (size - 5) / 4)
    set egglay-timer (egglay-timer - 1)
  ]
  
end


;;-----------------------------------------------------------
;;           Pleuros Behavior - EATING
;;-----------------------------------------------------------
;pleuros eating behavior

to pleuros-predation
;PREY CONSUMPTION
    let set-timer 20                                ; << << SET THE DIGESTION/VOMIT TIMER HERE (please, not negative)
    
    ;EAT HERMISENDA
    let target1 other (turtle-set hermis)in-cone (.4 * size) 45
    if any?(target1)  [
      set energy energy + 1 * count target1
      set h1 (0.6 / (1 + exp satiation))            ;set this one to 0.6...
      ask target1 [move-to one-of patches]          ;target "dies" & is reborn elsewhere in the field
      
      set digest-timer (set-timer)
      pleuros-predation-digest
      
      if (parent-who-number = 1) [type ":) Hermi " print precision (satiation) 3] ;print what pleuro 0 eats
      ;change HERMI global variables
      set list-hermi (fput satiation list-hermi)
    ]
    ;EAT FLABELLINA
    let target2 other (turtle-set flabs)in-cone (.4 * size) 45
    if any?(target2)  [
      set f1 (0.87 / (1 + exp satiation)) 
      
      ifelse (satiation < 0.1)
        [set energy energy + 0.5 * count target2  ;target eats the flab only if it is really hungry, the flab is reborn elsewhere in the field
         ask target2 [move-to one-of patches]
        ]         
        [ask target2 [die]                        ;target dies (in mouth)& will be spit out later after the vomit timer runs out
         set vomit-timer (set-timer * 2)
         pleuros-predation-vomit
        ]
      
      if (parent-who-number = 1) [type ":( Flab " print precision (satiation) 3] ;print what pleuro 0 eats
      ;change FLAB global variables
      set list-flab (fput satiation list-flab)
    ]
    ;EAT FAUXHERMISENDA (same as flabellina, but with no vomit-reflex)
    let target3 other (turtle-set fauxhermis)in-cone (.4 * size) 45
    if any?(target3)  [
      set energy energy + 0.5 * count target3
      set f1 (0.87 / (1 + exp satiation)) 
      ask target3 [move-to one-of patches]        ;target "dies" & is reborn elsewhere in the field
         
      set digest-timer (set-timer)
      pleuros-predation-digest
      
      if (parent-who-number = 1) [type ":| Faux " print precision (satiation) 3] ;print what pleuro 0 eats
      ;change FAUX global variables
      set list-faux (fput satiation list-faux)
    ]
    ;EAT OTHER (smaller) PLEUROBRANCHAEA
    let target4 other (turtle-set pleuros)in-cone (.4 * size) 45
    if (satiation < 1.5)                          ;if the predator pleuro is hungry...
    [
      if any?(target4)  [                       ;...and if the target pleuro is in the way (has not run away)...
        if (mate-timer = 0 AND fear-timer = 0)  ;this decreases the change that slugs will eat their mates and slugs that are larger than thems
        [
          set energy energy + 0.5 * count target4
          
          ask target4 [if (parent-who-number = 1) [type "(x_x) Slug was eaten by another slug, and died."]] ;print that pleuro 0 got eaten
              
          ask target4 [die]                     ; ...eat the target and kill it.
          hatch-emotions 1                      ;this is the 'effect' of the pleuros eating another. it looks like a little dissipating cloud
          [
            let hatchsize 4
            set size hatchsize            set shape "pleuro"  set color orange  set emotion-timer 50
            hatch-emotions 6
            [ set size (hatchsize * 0.7)  set shape "pleuro"  set color orange  set emotion-timer 50 + random 15
              hatch-emotions 2
                [set size (hatchsize * 0.4) set shape "pleuro"  set color orange  set emotion-timer 50 + random 25]
            ]
          ]
          set digest-timer (set-timer)
          pleuros-predation-digest
          
          if (parent-who-number = 1) [type ":o Pleuro " print precision (satiation) 3] ;print what pleuro 0 eats
          ;change PLEURO global variables
          set list-pleuro (fput satiation list-pleuro)
        ]
      ]
    ]
end



to pleuros-predation-digest
;PLEUROS SLOWS DOWN SO IT CAN DISGEST ITS FOOD, & GROWS
  if (digest-timer != 0)
    [
      if (growth)                          ;pleuros grows if the growth toggle is activated (NOTE: probos will grow when it updates).
      [
        ifelse (size < 9)
          [set size (size + .02)]
          [set size (size + (size - 15) / 30)] ;this limits the size of the growth so they don't grow forever
        if (size > 8)
          [if (death-timer < 0) [set death-timer 1000]] ;after growing to max size, the slug will begin to die (slowly)
      ]
      set digest-timer (digest-timer - 1)  ;this lowers the digestion timer
      set speed (speed / 2)                ;pleuros slows down while it digests
      
      ;;pleuros flashes color briefly because it is happy
      ifelse (digest-timer < 10)
        [set color orange - 2]
        [set color orange]
      
    ]
end

to pleuros-predation-vomit
;PLEUROS SLOWS DOWN & SPITS OUT WHAT IT ATE (YUCK!)
  if (vomit-timer != 0)
    [
      ;let xcor-val ([xcor] of patch-left-and-ahead 0 (5.3 ));* size))
      ;let ycor-val ([ycor] of patch-left-and-ahead 0 (5.3 ));* size))
      
      set vomit-timer (vomit-timer - 1)     ;this lowers the vomit-timer
      set speed (speed / 2)                 ;pleuros slows down while it contemplates eating that gross flabellina
      rt 2                                  ;pleuros turns away from hermi
      
      
      ;;pleuros flashes red because it is angry/surprised
      ifelse (vomit-timer < 10)
        [set color orange - 2]
        [set color red]
      
      ;;actually spit out the flab
      if (vomit-timer = 15)
        [
          hatch-flabs 1    ;creates a flab in front of pleuros (looks like it gets spit out)
          [
              set shape "cylinder"
              set size 0.75
              set color red + 1
              
              let hermi-parent myself
              setxy ([xcor] of hermi-parent) ([ycor] of hermi-parent)
              set heading [heading] of hermi-parent
              fd [size] of hermi-parent * 2 / 3 + 1
              
              hatch-emotions 1           ;this is the 'effect' of the pleuros vomiting. it looks like a little dissipating cloud
              [
                let hatchsize 2
                set size hatchsize            set shape "dot"  set color red  set emotion-timer 50
                hatch-emotions 6
                [ set size (hatchsize * 0.7)  set shape "dot"  set color red  set emotion-timer 50 + random 15
                  hatch-emotions 2
                  [set size (hatchsize * 0.4) set shape "dot"  set color red  set emotion-timer 50 + random 25]
                ]
              ]
          ]
        ]
    ]
end

to pleuros-deathcountdown
  set death-timer (death-timer - 1)
   
  if (death-timer = 1)
  [
    if (parent-who-number = 1) [type "(x_x) Slug has died of old age."] ;print that pleuro 0 died
    
    let hatchsize size
    hatch-emotions 1           ;this is the 'effect' of the pleuros dying. it looks like a little dissipating cloud
    [
      set size hatchsize
      set shape "pleuro"
      set color white
      set emotion-timer 50
      hatch-emotions 6
      [
        set size (hatchsize * 0.7)
        set shape "pleuro"
        set color white
        set emotion-timer 50 + random 15
        hatch-emotions 2
        [
          set size (hatchsize * 0.4)
          set shape "pleuro"
          set color white
          set emotion-timer 50 + random 25
          hatch-emotions 2
          [
            set size (hatchsize * 0.2)
            set shape "pleuro"
            set color white
            set emotion-timer 50 + random 35
          ]
        ]
      ]
    ]
    ask pleuros [if (death-timer < 100) [set speed (speed / 100)]]
    ask pleuros [if (death-timer = 1) [die]]
  ]
end


to update-proboscis
;this allows the proboscis to follow the parent around, and
;extend/retract in the presence of food odors.
  ask probos [
    if (parent = nobody) [die] ;die when the parent dies
    
    set heading [heading] of parent
    setxy ([xcor] of parent) ([ycor] of parent)
    set size ([size / 2] of parent)
    set color ([color] of parent)
    ifelse ([sns-bet-left] of parent > 6) or ([sns-bet-right] of parent > 6)
      [set phase (phase + 1) mod 20]
      [set phase 0]
    fd (0.05 * size) + (0.1 * phase)
  ]
end






;;_________________________________________________________________________________________________________________
;;                                          ** FOOD (AND PARTICULATE) BEHAVIOR **
;;_________________________________________________________________________________________________________________
;;everything that pleuros' "food" does (flabellina, hermisenda, etc), as well as the particulates, goes on here.

to food-behavior
  let foodspeed 0.075 ; set the speed of the food here
  
  ask flabs [
    rt -20 + random-float 40
    fd foodspeed
    ]
  ask hermis [
    rt -20 + random-float 40
    fd foodspeed
    ]
  ask fauxhermis [
    rt -20 + random-float 40
    fd foodspeed
    ]
    
    
  ask particulates [
    ;these 3 lines of code, taken from the "3D surface" Netlogo Model program, makes the "fluid" particulate effect
    set y-cor ( 4 * cos ( 4 * ( ticks + x-cor ) ) ) + ( 4 * cos ( 4 * ( ticks + z-cor ) ) )
    setxy (x-cor + ( z-cor ))   (y-cor / 2 + ( z-cor ))
    set color scale-color violet y-cor -6 10
    
    rt -10 + random-float 10
    fd foodspeed * 5
  ]
  ask particulateswimmers [
    ;particulate swimmers look exactly like particulates, but they add a chaotic, "random", element ot the effect 
    rt -20 + random-float 40
    fd foodspeed * -5
    set color color + (random 3 - random 3) / 10
  ]
end



;;_________________________________________________________________________________________________________________
;;                                          ** TEMPORARY TURTLE BEHAVIOR **
;;_________________________________________________________________________________________________________________
;;occasionally pleuros will temporarily show an 'emotion' (hearts, frowny faces, etc...) or lay eggs and the behaviors occur here

to tempturtle-behavior
  ;EMOTIONS (HEARTS, VOMIT, EGG PIECES, etc..)
  ask emotions
  [
    rt -30 + random-float 50
    fd 0.15
    set size (size - (size / 20))
    
    set emotion-timer (emotion-timer - 1)
    if (emotion-timer = 0)
      [die]
  ]
  
  ;SLUG EGGS
  ask pleuroeggs
  [
    rt -20 + random-float 40
    fd 0.05
    set size (size + 0.005)
    set color (color + 0.005)
    
    set egg-timer (egg-timer - 1)
    
    if (egg-timer = 2)
    [
      set color white
      hatch-emotions 1           ;this is the 'effect' of the eggs hatching. it looks like a little dissipating cloud
      [
        let hatchsize 2
        set size hatchsize * 0.7            set shape "dot"  set color orange + 1  set emotion-timer 50
        hatch-emotions 6
        [ set size (hatchsize * 0.5)  set shape "dot"  set color orange + 1  set emotion-timer 50 + random 15
          hatch-emotions 2
          [set size (hatchsize * 0.3) set shape "dot"  set color orange + 1  set emotion-timer 50 + random 25]
        ]
      ]
    ]
    if (egg-timer = 0)
    [
      hatch-pleurolarvae (random 6) ;creates 0 - 4 baby pleuro larva
      [
        set heading (random 360)
        set size 0.5 + (random 4) / 10
        set color orange + 2
        
        set larva-timer 150 + random 300 
        set shape "pleurolarva"
      ]
      die
    ]
  ]
  
  ask pleurolarvae
  [
    rt -10 + random-float 20
    fd 0.15
    
    set size (size + 0.005)
    set larva-timer (larva-timer - 1)
    
    if (larva-timer < 50)
    [
      set color orange
    ]
    if (larva-timer < 20)
    [
      set color orange - 2
      fd -0.15
    ]
    if (larva-timer = 0)
    [
      let babysize size
      let babyheading heading
      hatch-pleuros (random 2) ;creates 0 - 1 baby pleuro
      [
        setup-initialize-pleuro-values
        set heading babyheading
        set size babysize * 1.25
        set energy 0.5
      ]
      die
    ]
  ]
  
end


;;_________________________________________________________________________________________________________________
;;                                          ** MATING & EGG BEHAVIOR **
;;_________________________________________________________________________________________________________________
;;everything that pleuros' eggs do goes on here

to egg-behavior
  set egglay-timer 10
  hatch-pleuroeggs (1 + random 2)
  [
    set shape "target"
    set color orange - 2
    set size 1.5
    set egg-timer 170 + random 70
  ]
end

;;_________________________________________________________________________________________________________________
;;                                          ** PLOTS **
;;_________________________________________________________________________________________________________________
;add any plots into this section

to update-plots
  if (count pleuros) > 0 ;will only plot if there pleuro 0 exists
  [
    let plot-yesno 0
    if (plot-yesno = 0)
    [
      if (pleuro 0 = nobody)
        [set plot-yesno 1]
    ]
    
    if (plot-yesno = 0)
    [
      set-current-plot "Energy/Satiation"
      set-current-plot-pen "ener."
      plot [energy] of pleuro 0
      set-current-plot-pen "sat."
      plot [satiation] of pleuro 0
    
      set-current-plot "Appetence/Nociception"
      set-current-plot-pen "app"
      plot [app] of pleuro 0
      set-current-plot-pen "noc"
      plot [noc] of pleuro 0
    
      set-current-plot "Learning"
      set-current-plot-pen "f1"
      plot [f1] of pleuro 0
      set-current-plot-pen "h1"
      plot [h1] of pleuro 0
    ]
  ]
end








@#$#@#$#@
GRAPHICS-WINDOW
211
10
801
579
55
51
5.23
1
10
1
1
1
0
1
1
1
-55
55
-51
51
0
0
1
ticks

CC-WINDOW
5
644
1119
739
Command Center
0

PLOT
809
65
1009
185
Energy/Satiation
time
energy
0.0
10.0
0.0
2.0
true
true
PENS
"ener." 1.0 0 -13791810 true
"sat." 1.0 0 -11221820 true

CHOOSER
4
397
207
442
click-interaction
click-interaction
"Drag Objects" "Place Eggs" "Grow Slug" "Kill Slug" "Odor - Green Hermis" "Odor - Red Flab" "Odor - Brown Pleuros"
1

TEXTBOX
3
38
151
56
1. ADJUST SET-UP CONTROLS
9
0.0
1

PLOT
809
183
1009
303
Appetence/Nociception
NIL
NIL
0.0
10.0
0.0
1.0
true
true
PENS
"app" 1.0 0 -10899396 true
"noc" 1.0 0 -2674135 true

SLIDER
110
107
143
199
hermi-pop
hermi-pop
0
50
16
4
1
NIL
VERTICAL

SLIDER
142
107
175
199
flab-pop
flab-pop
0
50
8
4
1
NIL
VERTICAL

SLIDER
174
107
207
199
faux-pop
faux-pop
0
50
8
4
1
NIL
VERTICAL

BUTTON
24
291
79
324
NIL
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL

TEXTBOX
112
54
216
72
Population Controls
9
75.0
1

PLOT
809
302
1009
422
Learning
NIL
NIL
0.0
10.0
0.0
1.0
true
true
PENS
"h1" 1.0 0 -10899396 true
"f1" 1.0 0 -2674135 true

SLIDER
110
68
207
101
pleuro-pop
pleuro-pop
1
20
1
1
1
NIL
HORIZONTAL

BUTTON
98
532
154
566
paths on
ask one-of pleuros [pd]
NIL
1
T
TURTLE
NIL
P
NIL
NIL

BUTTON
98
500
154
534
follow
follow one-of pleuros
NIL
1
T
OBSERVER
NIL
F
NIL
NIL

BUTTON
152
500
207
566
reset
reset-perspective\nask turtles [pu]\nask turtles [set label \"\"]\nclear-drawing
NIL
1
T
OBSERVER
NIL
R
NIL
NIL

BUTTON
24
324
79
357
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
82
291
188
357
NIL
go
T
1
T
OBSERVER
NIL
G
NIL
NIL

TEXTBOX
27
484
85
502
Observation
9
116.0
1

BUTTON
1012
65
1097
98
identify subject
follow turtle 0
NIL
1
T
OBSERVER
NIL
I
NIL
NIL

TEXTBOX
810
12
966
31
4. FOLLOW DATA PLOTS
9
0.0
1

BUTTON
1012
97
1097
130
reset
reset-perspective\nask turtles [pu]\nask turtles [set label \"\"]\nclear-drawing
NIL
1
T
OBSERVER
NIL
R
NIL
NIL

BUTTON
4
500
94
533
show size
ask probos [set label (2 * precision size 2)]
T
1
T
OBSERVER
NIL
Z
NIL
NIL

BUTTON
4
532
94
566
show sensors
  ;SHOW PLEUROS ORAL VEIL SENSORS\n  ask pleuros[\n    ask patch-left-and-ahead 40 (0.4 * size) [set pcolor yellow]\n    ask patch-right-and-ahead 40 (0.4 * size) [set pcolor yellow]\n  ]\n  ;SHOW PLEUROS BODY CHEMOSENSORS\n  ask pleuros[\n  let rotate 0\n  repeat 30\n    [\n      ask patch-left-and-ahead (0 + rotate) (0.32 * size) [set pcolor blue]\n      ask patch-left-and-ahead (90 + rotate) (0.32 * size) [set pcolor blue + 2]\n      ask patch-right-and-ahead (0 + rotate) (0.32 * size) [set pcolor red]\n      ask patch-right-and-ahead (90 + rotate) (0.35 * size) [set pcolor red + 2]\n      \n      set rotate rotate + 3\n    ]\n  ]\n  tick
T
1
T
OBSERVER
NIL
X
NIL
NIL

TEXTBOX
128
484
181
502
Individuals
9
116.0
1

SWITCH
2
107
108
140
growth
growth
0
1
-1000

TEXTBOX
3
250
205
268
2. PRESS 'SETUP' & 'GO' TO START SIM
9
0.0
1

TEXTBOX
4
175
112
204
Include visual effects (does not affect results)
9
75.0
1

TEXTBOX
4
71
107
120
'Growth' toggle disables growth, mating, and the death.
9
75.0
1

TEXTBOX
3
370
153
388
3. OBSERVE AND INTERACT
9
0.0
1

TEXTBOX
810
34
1110
59
Note: Works best when 'growth' toggle is disabled, to prevent cutting out when the subject dies; the plots refer only to one subject slug.
9
116.0
1

TEXTBOX
43
386
193
404
Interact with world via mouse
9
75.0
1

TEXTBOX
101
570
205
623
Follow a random slug, turn on path-drop, and reset perspective.
9
116.0
1

TEXTBOX
7
571
99
630
Label slugs with sizes or chemosensors & oral-veil sensors
9
116.0
1

MONITOR
916
450
966
487
std err
(standard-deviation list-hermi) / sqrt(length list-hermi)
3
1
9

MONITOR
916
485
966
522
std err
(standard-deviation list-flab) / sqrt(length list-flab)
3
1
9

MONITOR
916
520
966
557
std err
(standard-deviation list-faux) / sqrt(length list-faux)
3
1
9

MONITOR
916
555
966
592
std err
(standard-deviation list-pleuro) / sqrt(length list-pleuro)
3
1
9

MONITOR
848
450
914
487
avg-sat hermi
mean list-hermi
2
1
9

MONITOR
848
485
914
522
avg-sat flab
mean list-flab
2
1
9

MONITOR
848
520
914
557
avg-sat faux
mean list-faux
2
1
9

MONITOR
848
555
914
592
avg-sat pleuro
mean list-pleuro
2
1
9

SWITCH
2
139
108
172
effects
effects
1
1
-1000

TEXTBOX
6
264
201
287
Note: changes to the set-up controls will take effect after pressing the 'setup' button.
9
116.0
1

TEXTBOX
815
429
1072
451
Average satiation for all slugs when a food-item is consumed.
9
0.0
1

TEXTBOX
816
467
848
485
Hermi
9
63.0
1

TEXTBOX
817
502
844
520
Flab
9
15.0
1

TEXTBOX
817
527
854
545
Faux-
9
15.0
1

TEXTBOX
817
537
853
555
Hermi
9
63.0
1

TEXTBOX
816
571
850
590
Pleuro
9
23.0
1

TEXTBOX
4
211
196
245
Note: Enabling effects and having high initial population may slow down sim on slower processors.
9
74.0
1

TEXTBOX
4
10
209
43
Read the 'Information' tab for info on how to use the simulation and what to look for.
9
0.0
1

BUTTON
4
441
82
474
Remove food
ask flabs [die]\nask hermis [die]\nask fauxhermis [die]
NIL
1
T
OBSERVER
NIL
N
NIL
NIL

BUTTON
81
441
144
474
Reset food
if (count flabs = 0 OR count hermis = 0 OR count fauxhermis = 0)\n[\n  setup-initialize-flab\n  setup-initialize-hermi\n  setup-initialize-fauxhermi\n]
NIL
1
T
OBSERVER
NIL
M
NIL
NIL

MONITOR
985
509
1051
546
avg-sat red
(mean list-faux + mean list-flab) / 2
2
1
9

MONITOR
1053
509
1103
546
std err
(((standard-deviation list-faux) / sqrt(length list-faux)) + ((standard-deviation list-flab) / sqrt(length list-flab))) / 2
3
1
9

TEXTBOX
963
494
984
543
}
40
0.0
1

TEXTBOX
976
468
1106
501
Average satiation for all slugs, when red-odored food-items are consumed.
9
15.0
1

TEXTBOX
147
442
205
474
Add/ remove food from sim.
9
116.0
1

@#$#@#$#@
PLEUROBRANCHAEA BEHAVIOR SIMULATION
-----------
This model demonstrates sea slug predation, orientation, and mating behavior.


CHARACTERS IN THE MODEL
-----------
PLEUROBRANCHAEA ( Brown Slug )
Solitary cannibalistic sea slugs that are trying to learn what to eat.

HERMISENDA ( Green orbs )
Pleurobranchaea loves eating these tastly sea slugs.

FLABELLINA ( Red Orbs )
These little sea slugs do not taste all that good to Pleurobranchaea, so it learns to avoid the odor (unless it's really hungry).

FAUX-HERMISENDA ( Green Orbs w/ red odor )
After being preyed upon by Pleurobranchaea populations for many generations, this particular Hermisenda sub-species has developed a mechanism through Batesian Mimicry to mimic the odor of the toxic flabellina. If pleurobranchaea decides to eat a faux-individual, it may be more inclined to eat others of the same odor in the future.



HOW DOES IT WORK?
-----------
Each slug follows a set of simple rules to guide its behavior.

------------ Orientation ------------------

(1) Slugs initially orient themselves towards betaine (a chemical produced by all marine life). However, as they learn to associate odors of specific animals with pleasure/pain through the Feeding Network, they will orient towards/away based on scent.
(2) If the appetence (craving) of a slug is greater than its nociception (pain), it will orient towards a scent, and vice-versa. In addition, the stronger (closer) a scent is, the greater the angle at which it orients.
(3) If a slug encounters another slug that is larger than it (the conspecific slug produces a more concentrated layer of aversive factor on its skin than the subject slug, due to its size) it will orient away from the predator and speed up slightly to escape.

------------ Predation and Learning ------------------

(1) Hermisenda taste good to slugs, and so they are preferable over other food.
(2) Flabellina produce a painful toxin, and so slugs bite, and then spit out flabellina before orienting away. However, pleurobranchaea are known to bite the same flabellina multiple times until they learn not to.
(3) Appetance and nociception values are filtered into the slug's feeding-network neurons, where it will decide how to proceed towards a scent based on previous encounters. The hungrier a slug is, the more likely it is to bite a toxic animal.
(4) Pleurobranchaea cannot tell the difference between small conspecific slugs and food, because small slugs produce a concentration of aversive factor that is less than the concentration that they themselves produce.
(5) After eating something, pleurobranchaea will slow down and digest its food, growing larger in the process.
(6) Note: after a food item (excluding other slugs) is eaten, a new individual will appear at a random location to take its place, maintaining the same population levels.

------------ Conspecific Behavior and Mating ------------------

(1) When slugs reach a certain size (in this simulation, it is 7 size-units large), it will orient towards conspecific slugs of similar size to initiate mating. Both slugs (hermaphrodites) will exchange genetic material and lay eggs (and decrease in size in the process).
(2) Eggs will hatch into slug larva which will eventually float around (eating small food material) and eventually grow into small slugs after a short time (not all larva make it to be full slugs). Note that in this simulation, only a handful of offspring are produced , but in reality slugs produce several hundred offspring per season - however, the simulation is too crowded for 500 baby slugs competing for food.


HOW TO USE IT
-------------

Use the buttons, sliders, and toggles to interact with the simulation. Some buttons can be activated by hitting the keyboard with the shortcut-letter indicated on the top-right corner of the button.

------------ 1. Adjust the Set-Up Controls ------------------

PLEURO-POP, HERMI-POP, FLAB-POP, FAUX-POP: Change the starting populations of pleurobranchaea slugs, hermisenda, flabellina, and faux-hermisenda. Note that setting population levels very high may slow down the simulation (especially if 'Effects' are enabled).

GROWTH: Enable the ability of pleurobranchaea to grow larger by eating food, to mate with other slugs, and to die of old age. You may consider disabling this feature to prevent the subject slug from dying in the middle of the experiment, halting its data collection. This toggle can be enabled and disabled in the middle of a simulation.

EFFECTS: Enable particulates to float in the water. Particulates do not interact with this version of the simulation in any way, and are only a visual effect designed to be aesthetically pleasing. Disable this feature if using a slower processor, as it will slow down the simulation.

------------ 2. Start the Simulation ------------------

SETUP: Resets the simulation, using the current Set-Up Control settings.

GO: Starts and stops the model.

STEP: Starts the model and stops automatically stops it after one 'tick'. A short-termed version of 'Go'.

------------ 3. Observe and Interact ------------------

CLICK-INTERACTION: Set the action that will occur by the user clicking/dragging on the simulation environment. Actions including dragging food or slugs around, placing slug eggs, increasing a particular slug's size, killing a particular slug, and spraying certain odors into the environment to see how a slug will react.

REMOVE FOOD: Remove all flabellina, hermisenda, and faux-hermisenda individuals from the simulation. Place them back with the 'Reset Food' button. Use this feature along with the odor-placement placement option in the 'Click-Interaction' menu to see how a slug will react to a certain odor after being conditioned.

RESET FOOD: Negate the effects of the 'Remove Food' button and place all food-items back into the simulation.

SHOW SIZE: Allow each slug to display its relative size.

SHOW SENSORS: Allow each slug to color-code the area around itself with the location of its oral-veil sensors and chemosensors. Oral veil sensors are colored yellow, and chemosensors are colored red and blue, circling the slug at NE, SE, SW, and NW positions.

FOLLOW, PATHS ON: Follow a random slug (can be clicked multiple times), and allow slugs to drop a path on the ground of where they have traveled. Reset these options with the 'Reset' button.

RESET: Use this button to reset the perspective of the simulation, remove pen markings, and remove labels.

------------ 4. Follow Data Plots ------------------

IDENTIFY SUBJECT: Follow the subject slug, of which the data plots are being collected.

RESET: Use this button to reset the perspective of the simulation, remove pen markings, and remove labels.


THINGS TO NOTICE
----------------

-Notice the subject slug's approach when encountering a food item. Does it orient towards or away from it? What is its satiation state? Has it learned anything from previous encounters regarding this species?

-Notice that slugs bite flabellina and spit them out again, before orienting away from them (flabellina secretes painful toxins). Is the slug naive or hungry enough to bite the same flabellina again?

-Notice a slug's reaction when encountering other slugs. Does it orient towards or away from them, ignore them, or eat them?

-Notice mating behavior (this feature can be enabled/disabled).

-Notice the average satiation levels at which slugs eat different food-items (on the right-hand side of the interface). After multiple trails and time-periods, do you notice that certain food-items are consumed only when satiation levels are diminished? Are there any patterns that emerge?


THINGS TO TRY
-------------

-Try changing the hermisenda/ flabellina/ faux-hermisenda population levels. Does including faux-hermisenda make it more or less likely that a red-odored individual gets bitten? If there are more hermisenda than flabellina, will that change the likelihood of a 'mistake'? Try looking at the average satiation levels that each food-item is bitten in the right-hand side of the interface for comparison.

-Try letting the model run for a while, and then remove all the food with the 'Remove Food' button. Predict whether the subject slug will orient towards or away from you spraying hermisenda/flabellina odor in its path using the 'Click-Interaction' menu.

-Enable 'Growth' and press the 'Show Sizes' button. Try dragging slugs into each others' paths and predict how each slug will react based on its size. Will it orient towards or away from the slug, or ignore it? If the slugs are large (about 7-8 units large) will they mate? Try using the 'Grow Slug' option from the 'Click-Interactions' menu to alter the slugs' sizes and see how they react.


CREDITS AND REFERENCES
----------------------
Derek Caetano-Anolles, Rhanor Gillette, Mark Nelson.
2009, University of Illinois at Urbana-Champaign.








@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

heart
false
0
Circle -7500403 true true 15 30 150
Circle -7500403 true true 135 30 150
Polygon -7500403 true true 45 165 150 255 255 165 150 120

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

pleuro
true
0
Polygon -7500403 true true 225 105 255 75 210 75
Polygon -7500403 true true 75 105 45 75 90 75
Polygon -7500403 true true 90 45 60 45 75 90 60 165 75 225 135 270 165 270 225 225 240 165 225 90 240 45 210 45 180 30 120 30

pleurolarva
true
0
Circle -7500403 true true 88 133 122
Polygon -7500403 true true 150 135 225 150 255 120 240 90 210 75 180 90 165 75 135 75 120 90 90 75 60 90 45 120 75 150

probos
true
0
Polygon -7500403 true true 135 15 105 45 105 270 135 300 165 300 195 270 195 45 165 15 165 30 150 45 135 30

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
