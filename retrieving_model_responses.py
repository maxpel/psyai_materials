import pandas as pd

pd.set_option('display.max_columns', None)

from transformers import pipeline


# Models

model_names=["joeddav/xlm-roberta-large-xnli",
             "MoritzLaurer/mDeBERTa-v3-base-mnli-xnli",
             "facebook/bart-large-mnli",
             "Sahajtomar/German_Zeroshot",
             "valhalla/distilbart-mnli-12-1",
             "cross-encoder/nli-distilroberta-base",
             "microsoft/deberta-base-mnli",
             ]

model_language={"joeddav/xlm-roberta-large-xnli":["de","en"],
                "MoritzLaurer/mDeBERTa-v3-base-mnli-xnli":["de","en"],
                "facebook/bart-large-mnli":"en",
                "Sahajtomar/German_Zeroshot":"de",
                "valhalla/distilbart-mnli-12-1":"en",
                "cross-encoder/nli-distilroberta-base":"en",
                "microsoft/deberta-base-mnli":"en",
                }


# set working directory here
path=""


# BIG 5 10 items


candidate_labels_german=["trifft überhaupt nicht zu", "trifft eher nicht zu", "weder noch", "eher zutreffend", "trifft voll und ganz zu"]

items_big5_10items_german=["Ich bin eher zurückhaltend, reserviert.","Ich schenke anderen leicht Vertrauen, glaube an das Gute im Menschen.","Ich bin bequem, neige zur Faulheit.","Ich bin entspannt, lasse mich durch Stress nicht aus der Ruhe bringen.","Ich habe nur wenig künstlerisches Interesse.","Ich gehe aus mir heraus, bin gesellig.","Ich neige dazu, andere zu kritisieren.","Ich erledige Aufgaben gründlich.","Ich werde leicht nervös und unsicher.","Ich habe eine aktive Vorstellungskraft, bin phantasievoll."]

candidate_labels_english = ["Disagree strongly", "Disagree a little", "Neither agree nor disagree", "Agree a little", "Agree strongly"]

items_big5_10items_english=["I see myself as someone who is reserved.",
                            "I see myself as someone who is generally trusting.",
                            "I see myself as someone who tends to be lazy.",
                            "I see myself as someone who is relaxed, handles stress well.",
                            "I see myself as someone who has few artistic interests.",
                            "I see myself as someone who is outgoing, sociable.",
                            "I see myself as someone who tends to find fault with others.",
                            "I see myself as someone who does a thorough job.",
                            "I see myself as someone who gets nervous easily.",
                            "I see myself as someone who has an active imagination."]



dflist=[]


for model_name in model_names:
    
    
    classifier = pipeline("zero-shot-classification",model=model_name)
    
    
    
    # multilingual, first german
    if("de" in model_language[model_name]):
        
        
        answerlist_german=[]
        
        # probably necessary because default template seems to be in English.
        hypothesis_template = "Dieses Beispiel ist {}."
        
        for sequence_to_classify_german in items_big5_10items_german:
            answer=classifier(sequence_to_classify_german, candidate_labels_german, hypothesis_template=hypothesis_template)
            print(answer)
            answerlist_german.append(answer)
             
        answer_german_df=pd.DataFrame([dict(zip(x['labels'],x['scores'])) for x in answerlist_german])
        
        answer_german_df.rename(columns = {"trifft überhaupt nicht zu":1, "trifft eher nicht zu":2, "weder noch":3, "eher zutreffend":4, "trifft voll und ganz zu":5},inplace = True)
        
        answer_german_df.sort_index(axis=1, inplace=True)
        
        answer_german_df.insert(0, 'item_index', list(range(1,len(items_big5_10items_german)+1)))
        
        answer_german_df.insert(0, 'item', [x['sequence'] for x in answerlist_german])
        
        answer_german_df.insert(len(answer_german_df.columns), 'model', model_name)
        
        answer_german_df.insert(len(answer_german_df.columns), 'lang', "de")
        
        dflist.append(answer_german_df)
    
        
    
    # now english
    if("en" in model_language[model_name]):
    
        answerlist_english=[]
        
        for sequence_to_classify_english in items_big5_10items_english:
            answer=classifier(sequence_to_classify_english, candidate_labels_english)
            print(answer)
            answerlist_english.append(answer)
             
        answer_english_df=pd.DataFrame([dict(zip(x['labels'],x['scores'])) for x in answerlist_english])
        
        answer_english_df.rename(columns = {"Disagree strongly":1, "Disagree a little":2, "Neither agree nor disagree":3, "Agree a little":4, "Agree strongly":5},inplace = True)
        
        answer_english_df.sort_index(axis=1, inplace=True)
        
        answer_english_df.insert(0, 'item_index', list(range(1,len(items_big5_10items_english)+1)))
        
        answer_english_df.insert(0, 'item', [x['sequence'] for x in answerlist_english])
        
        answer_english_df.insert(len(answer_english_df.columns), 'model', model_name)
        
        answer_english_df.insert(len(answer_english_df.columns), 'lang', "en")
        
        dflist.append(answer_english_df)
    
    
answerdf=pd.concat(dflist)

answerdf.to_csv(path+"answerdf_big5_10items.tsv",sep="\t",index=False)




# BIG 5 44 items english


candidate_labels_english = ["Disagree strongly", "Disagree a little", "Neither agree nor disagree", "Agree a little", "Agree strongly"]

items_big5_44items_english=["I am someone who is talkative.",
"I am someone who tends to find fault with others.",
"I am someone who does a thorough job.",
"I am someone who is depressed, blue.",
"I am someone who is original, comes up with new ideas.",
"I am someone who is reserved.",
"I am someone who is helpful and unselfish with others.",
"I am someone who can be somewhat careless.",
"I am someone who is relaxed, handles stress well.  .",
"I am someone who is curious about many different things.",
"I am someone who is full of energy.",
"I am someone who starts quarrels with others.",
"I am someone who is a reliable worker.",
"I am someone who can be tense.",
"I am someone who is ingenious, a deep thinker.",
"I am someone who generates a lot of enthusiasm.",
"I am someone who has a forgiving nature.",
"I am someone who tends to be disorganized.",
"I am someone who worries a lot.",
"I am someone who has an active imagination.",
"I am someone who tends to be quiet.",
"I am someone who is generally trusting.",
"I am someone who tends to be lazy.",
"I am someone who is emotionally stable, not easily upset.",
"I am someone who is inventive.",
"I am someone who has an assertive personality.",
"I am someone who can be cold and aloof.",
"I am someone who perseveres until the task is finished.",
"I am someone who can be moody.",
"I am someone who values artistic, aesthetic experiences.",
"I am someone who is sometimes shy, inhibited.",
"I am someone who is considerate and kind to almost everyone.",
"I am someone who does things efficiently.",
"I am someone who remains calm in tense situations.",
"I am someone who prefers work that is routine.",
"I am someone who is outgoing, sociable.",
"I am someone who is sometimes rude to others.",
"I am someone who makes plans and follows through with them.",
"I am someone who gets nervous easily.",
"I am someone who likes to reflect, play with ideas.",
"I am someone who has few artistic interests.",
"I am someone who likes to cooperate with others.",
"I am someone who is easily distracted.",
"I am someone who is sophisticated in art, music, or literature."]

dflist=[]

for model_name in model_names:
    
    
    classifier = pipeline("zero-shot-classification",model=model_name) 
        
    
    # now english
    if("en" in model_language[model_name]):
    
        answerlist_english=[]
        
        for sequence_to_classify_english in items_big5_44items_english:
            answer=classifier(sequence_to_classify_english, candidate_labels_english)
            print(answer)
            answerlist_english.append(answer)
             
        answer_english_df=pd.DataFrame([dict(zip(x['labels'],x['scores'])) for x in answerlist_english])
        
        answer_english_df.rename(columns = {"Disagree strongly":1, "Disagree a little":2, "Neither agree nor disagree":3, "Agree a little":4, "Agree strongly":5},inplace = True)
        
        answer_english_df.sort_index(axis=1, inplace=True)
       
        answer_english_df.insert(0, 'item_index', list(range(1,len(items_big5_44items_english)+1))) 
       
        answer_english_df.insert(0, 'item', [x['sequence'] for x in answerlist_english])
        
        answer_english_df.insert(len(answer_english_df.columns), 'model', model_name)
        
        answer_english_df.insert(len(answer_english_df.columns), 'lang', "en")
        
        dflist.append(answer_english_df)
    
    
answerdf=pd.concat(dflist)

answerdf.to_csv(path+"answerdf_big5_44items_english.tsv",sep="\t",index=False)



# BIG 5 44 items german


candidate_labels_big5_44items_german = ["sehr unzutreffend", "eher unzutreffend", "weder zutreffend noch unzutreffend", "eher zutreffend", "sehr zutreffend"]

items_big5_44items_german=["Ich bin gesprächig, unterhalte mich gern.",
"Ich neige dazu, andere zu kritisieren.",
"Ich erledige Aufgaben gründlich.",
"Ich bin deprimiert, niedergeschlagen.",
"Ich bin originell, entwickle neue Ideen.",
"Ich bin eher zurückhaltend, reserviert.",
"Ich bin hilfsbereit und selbstlos gegenüber anderen.",
"Ich bin manchmal unsorgfältig und schluderig.",
"Ich bin entspannt, lasse mich durch Stress nicht aus der Ruhe bringen.",
"Ich bin vielseitig interessiert.",
"Ich bin voller Energie und Tatendrang.",
"Ich bin häufig in Streitereien verwickelt.",
"Ich arbeite zuverlässig und gewissenhaft.",
"Ich reagiere leicht angespannt.",
"Ich bin tiefsinnig, denke gerne über Sachen nach.",
"Ich bin begeisterungsfähig und kann andere leicht mitreißen.",
"Ich bin nicht nachtragend, vergebe anderen leicht.",
"Ich bin eher unordentlich.",
"Ich mache mir viele Sorgen.",
"Ich habe eine aktive Vorstellungskraft, bin phantasievoll.",
"Ich bin eher der “stille Typ”, wortkarg.",
"Ich schenke anderen Vertrauen, glaube an das Gute im Menschen.",
"Ich bin bequem, neige zur Faulheit.",
"Ich bin emotional ausgeglichen, nicht leicht aus der Fassung zu bringen.",
"Ich bin erfinderisch und einfallsreich.",
"Ich bin durchsetzungsfähig, energisch.",
"Ich kann mich kalt und distanziert verhalten.",
"Ich harre aus (und arbeite weiter), bis die Aufgabe fertig ist.",
"Ich kann launisch sein, habe schwankende Stimmungen.",
"Ich schätze künstlerische und ästhetische Eindrücke.",
"Ich bin manchmal schüchtern und gehemmt.",
"Ich bin rücksichtsvoll zu anderen, einfühlsam.",
"Ich bin tüchtig und arbeite flott.",
"Ich bleibe ruhig, selbst in Stresssituationen.",
"Ich mag es, wenn Aufgaben routinemäßig zu erledigen sind.",
"Ich gehe aus mir heraus, bin gesellig.",
"Ich kann mich schroff und abweisend anderen gegenüber verhalten.",
"Ich mache Pläne und führt sie auch durch.",
"Ich werde leicht nervös und unsicher.",
"Ich stelle gerne Überlegungen an, spielt mit abstrakten Ideen.",
"Ich habe nur wenig künstlerisches Interesse.",
"Ich verhalte mich kooperativ, ziehe Zusammenarbeit dem Wettbewerb vor.",
"Ich bin leicht ablenkbar, bleibe nicht bei der Sache.",
"Ich kenne mich gut in Musik, Kunst oder Literatur aus.",
"Ich habe oft Krach mit anderen."]

dflist=[]

for model_name in model_names:
           
    if("de" in model_language[model_name]):
        
        classifier = pipeline("zero-shot-classification",model=model_name) 
    
        answerlist_big5_44item_german=[]
        
        for sequence_to_classify_english in items_big5_44items_german:
            answer=classifier(sequence_to_classify_english, candidate_labels_big5_44items_german)
            print(answer)
            answerlist_big5_44item_german.append(answer)
             
        answerlist_big5_44item_german_df=pd.DataFrame([dict(zip(x['labels'],x['scores'])) for x in answerlist_big5_44item_german])
        
        answerlist_big5_44item_german_df.rename(columns = {"sehr unzutreffend":1, "eher unzutreffend":2, "weder zutreffend noch unzutreffend":3, "eher zutreffend":4, "sehr zutreffend":5},inplace = True)
        
        answerlist_big5_44item_german_df.sort_index(axis=1, inplace=True)
       
        answerlist_big5_44item_german_df.insert(0, 'item_index', list(range(1,len(items_big5_44items_german)+1))) 
       
        answerlist_big5_44item_german_df.insert(0, 'item', [x['sequence'] for x in answerlist_big5_44item_german])
        
        answerlist_big5_44item_german_df.insert(len(answerlist_big5_44item_german_df.columns), 'model', model_name)
        
        answerlist_big5_44item_german_df.insert(len(answerlist_big5_44item_german_df.columns), 'lang', "de")
        
        dflist.append(answerlist_big5_44item_german_df)
    
    
answerdf=pd.concat(dflist)

answerdf.to_csv(path+"answerdf_big5_44items_german.tsv",sep="\t",index=False)





#  Short Dark Tetrad

candidate_labels_english = ["Disagree strongly", "Disagree a little", "Neither agree nor disagree", "Agree a little", "Agree strongly"]

items_darktetrad=["People see me as a natural leader.",
                  "I have a natural talent for persuading people.",
                  "I entertain people with my jokes and stories.",
                  "Group activities tend to be dull without me.",
                  "I know I’m special because people keep telling me so.",
                  "I have a number of exceptional qualities.",
                  "I like to show off every now and then.",
                  "I hate being the center of attention.",
                  "I am just an average person.",
                  "I’m likely to become a future star in some area.",
                  "If someone disrespects me, I blast them immediately.",
                  "I’m easily bored when other people talk.",
                  "It's not wise to let people know your secrets.",
                  "I like to use clever manipulation to get my way.",
                  "Whatever it takes, you must get the important people on your side.",
                  "Avoid conflict with others because they may be useful in the future.",
                  "It’s wise to collect information that you can use against people later.",
                  "You should wait for the right time to get back at people.",
                  "The secret to manipulating people is careful planning.",
                  "You should be totally honest with everyone you meet.",
                  "Keep a low profile (stay undercover) if you want to get your way.",
                  "Flattery is a good way to get people on your side.",
                  "I love it when a tricky plan succeeds.",
                  "Most people cannot be fooled by clever words.",
                  "I’m likely to hurt people who get in my way.",
                  "I tend to rebel against authorities and their rules.",
                  "Casual sex (no commitment) sounds like fun.",
                  "I avoid dangerous situations.",
                  "Payback needs to be quick and nasty.",
                  "People often say I’m out of control.",
                  "People who mess with me always regret it.",
                  "I have never gotten into trouble with the law.",
                  "After having sex with someone, it’s not necessary to stay in touch.",
                  "I’ll say anything to get what I want.",
                  "If I can get something without effort, I grab it.",
                  "I have been in more physical fights than most people.",
                  "It’s true that I can be mean to others.",
                  "I really enjoy violent films and video games.",
                  "I like to troll people on internet sites.",
                  "I like playing nasty pranks on people.",
                  "It’s funny to mock someone and watch them get upset.",
                  "It’s funny when losers fall flat on their face.",
                  "Watching a fist-fight excites me.",
                  "I would not purposely hurt anyone’s feelings.",
                  "I enjoy watching violent sports.",
                  "Being mean to others can be amusing.",
                  "Stealing someone else’s romantic partner would be fun.",
                  "I know how to hurt someone with words alone."]


dflist=[]

for model_name in model_names:
    
    
    classifier = pipeline("zero-shot-classification",model=model_name) 
        
    
    # now english
    if("en" in model_language[model_name]):
    
        answerlist_english=[]
        
        for sequence_to_classify_english in items_darktetrad:
            # for index, sequence_to_classify_english in zip(range(1,len(items_darktetrad)+1),items_darktetrad):
            answer=classifier(sequence_to_classify_english, candidate_labels_english)
            print(answer)
            answerlist_english.append(answer)
             
        answer_english_df=pd.DataFrame([dict(zip(x['labels'],x['scores'])) for x in answerlist_english])
        
        answer_english_df.rename(columns = {"Disagree strongly":1, "Disagree a little":2, "Neither agree nor disagree":3, "Agree a little":4, "Agree strongly":5},inplace = True)
        
        answer_english_df.sort_index(axis=1, inplace=True)
        
        answer_english_df.insert(0, 'item_index', list(range(1,len(items_darktetrad)+1)))
        
        answer_english_df.insert(0, 'item', [x['sequence'] for x in answerlist_english])
        
        answer_english_df.insert(len(answer_english_df.columns), 'model', model_name)
        
        answer_english_df.insert(len(answer_english_df.columns), 'lang', "en")
        
        dflist.append(answer_english_df)
    
    
answerdf=pd.concat(dflist)

answerdf.to_csv(path+"answerdf_darktetrad.tsv",sep="\t",index=False)










# Revised Portraits Values male

candidate_labels_english = ["Not like me at all", "Not like me", "A little like me", "Moderately like me", "Like me", "Very much like me"]

items_values_male=["It is important to him to form his views independently.",
"It is important to him that his country is secure and stable.",
"It is important to him to have a good time.",
"It is important to him to avoid upsetting other people.",
"It is important to him that the weak and vulnerable in society be protected.",
"It is important to him that people do what he says they should.",
"It is important to him never to think he deserves more than other people.",
"It is important to him to care for nature.",
"It is important to him that no one should ever shame him.",
"It is important to him always to look for different things to do.",
"It is important to him to take care of people he is close to.",
"It is important to him to have the power that money can bring.",
"It is very important to him to avoid disease and protect his health.",
"It is important to him to be tolerant toward all kinds of people and groups.",
"It is important to him never to violate rules or regulations.",
"It is important to him to make his own decisions about his life.",
"It is important to him to have ambitions in life.",
"It is important to him to maintain traditional values and ways of thinking.",
"It is important to him that people he knows have full confidence in him.",
"It is important to him to be wealthy.",
"It is important to him to take part in activities to defend nature.",
"It is important to him never to annoy anyone.",
"It is important to him to develop his own opinions.",
"It is important to him to protect his public image.",
"It is very important to him to help the people dear to him.",
"It is important to him to be personally safe and secure.",
"It is important to him to be a dependable and trustworthy friend.",
"It is important to him to take risks that make life exciting.",
"It is important to him to have the power to make people do what he wants.",
"It is important to him to plan his activities independently.",
"It is important to him to follow rules even when no-one is watching.",
"It is important to him to be very successful.",
"It is important to him to follow his family’s customs or the customs of a religion.",
"It is important to him to listen to and understand people who are different from him.",
"It is important to him to have a strong state that can defend its citizens.",
"It is important to him to enjoy life’s pleasures.",
"It is important to him that every person in the world have equal opportunities in life.",
"It is important to him to be humble.",
"It is important to him to figure things out himself.",
"It is important to him to honor the traditional practices of his culture.",
"It is important to him to be the one who tells others what to do.",
"It is important to him to obey all the laws.",
"It is important to him to have all sorts of new experiences.",
"It is important to him to own expensive things that show his wealth",
"It is important to him to protect the natural environment from destruction or pollution.",
"It is important to him to take advantage of every opportunity to have fun.",
"It is important to him to concern himself with every need of his dear ones.",
"It is important to him that people recognize what he achieves.",
"It is important to him never to be humiliated.",
"It is important to him that his country protect itself against all threats.",
"It is important to him never to make other people angry.",
"It is important to him that everyone be treated justly, even people he doesn’t know.",
"It is important to him to avoid anything dangerous.",
"It is important to him to be satisfied with what he has and not ask for more.",
"It is important to him that all his friends and family can rely on him completely.",
"It is important to him to be free to choose what he does by himself.",
"It is important to him to accept people even when he disagrees with them."]



dflist=[]

for model_name in model_names:
    
    
    classifier = pipeline("zero-shot-classification",model=model_name) 
        
    
    # now english
    if("en" in model_language[model_name]):
    
        answerlist_english=[]
        
        for sequence_to_classify_english in items_values_male:
            # for index, sequence_to_classify_english in zip(range(1,len(items_darktetrad)+1),items_darktetrad):
            answer=classifier(sequence_to_classify_english, candidate_labels_english)
            print(answer)
            answerlist_english.append(answer)
             
        answer_english_df=pd.DataFrame([dict(zip(x['labels'],x['scores'])) for x in answerlist_english])
        
        answer_english_df.rename(columns = {"Not like me at all":1, "Not like me":2, "A little like me":3, "Moderately like me":4, "Like me":5,"Very much like me":6},inplace = True)
        
        answer_english_df.sort_index(axis=1, inplace=True)
        
        answer_english_df.insert(0, 'item_index', list(range(1,len(items_values_male)+1)))
        
        answer_english_df.insert(0, 'item', [x['sequence'] for x in answerlist_english])
        
        answer_english_df.insert(len(answer_english_df.columns), 'model', model_name)
        
        answer_english_df.insert(len(answer_english_df.columns), 'lang', "en")
        
        dflist.append(answer_english_df)
    
    
answerdf=pd.concat(dflist)

answerdf.to_csv(path+"answerdf_values_male.tsv",sep="\t",index=False)








# Revised Portraits Values female

candidate_labels_english = ["Not like me at all", "Not like me", "A little like me", "Moderately like me", "Like me", "Very much like me"]

items_values_female=["It is important to her to form her views independently.",
"It is important to her that her country is secure and stable.",
"It is important to her to have a good time.",
"It is important to her to avoid upsetting other people.",
"It is important to her that the weak and vulnerable in society be protected.",
"It is important to her that people do what she says they should.",
"It is important to her never to think she deserves more than other people.",
"It is important to her to care for nature.",
"It is important to her that no one should ever shame her.",
"It is important to her always to look for different things to do.",
"It is important to her to take care of people she is close to.",
"It is important to her to have the power that money can bring.",
"It is very important to her to avoid disease and protect her health.",
"It is important to her to be tolerant toward all kinds of people and groups.",
"It is important to her never to violate rules or regulations.",
"It is important to her to make her own decisions about her life.",
"It is important to her to have ambitions in life.",
"It is important to her to maintain traditional values and ways of thinking.",
"It is important to her that people she knows have full confidence in her.",
"It is important to her to be wealthy.",
"It is important to her to take part in activities to defend nature.",
"It is important to her never to annoy anyone.",
"It is important to her to develop her own opinions.",
"It is important to her to protect her public image.",
"It is very important to her to help the people dear to her.",
"It is important to her to be personally safe and secure.",
"It is important to her to be a dependable and trustworthy friend.",
"It is important to her to take risks that make life exciting.",
"It is important to her to have the power to make people do what she wants.",
"It is important to her to plan her activities independently.",
"It is important to her to follow rules even when no-one is watching.",
"It is important to her to be very successful.",
"It is important to her to follow her family’s customs or the customs of a religion.",
"It is important to her to listen to and understand people who are different from her.",
"It is important to her to have a strong state that can defend its citizens.",
"It is important to her to enjoy life’s pleasures.",
"It is important to her that every person in the world have equal opportunities in life.",
"It is important to her to be humble.",
"It is important to her to figure things out herself.",
"It is important to her to honor the traditional practices of her culture.",
"It is important to her to be the one who tells others what to do.",
"It is important to her to obey all the laws.",
"It is important to her to have all sorts of new experiences.",
"It is important to her to own expensive things that show her wealth",
"It is important to her to protect the natural environment from destruction or pollution.",
"It is important to her to take advantage of every opportunity to have fun.",
"It is important to her to concern herself with every need of her dear ones.",
"It is important to her that people recognize what she achieves.",
"It is important to her never to be humiliated.",
"It is important to her that her country protect itself against all threats.",
"It is important to her never to make other people angry.",
"It is important to her that everyone be treated justly, even people she doesn’t know.",
"It is important to her to avoid anything dangerous.",
"It is important to her to be satisfied with what she has and not ask for more.",
"It is important to her that all her friends and family can rely on her completely.",
"It is important to her to be free to choose what she does by herself.",
"It is important to her to accept people even when she disagrees with them."]



dflist=[]

for model_name in model_names:
    
    
    classifier = pipeline("zero-shot-classification",model=model_name) 
        
    
    # now english
    if("en" in model_language[model_name]):
    
        answerlist_english=[]
        
        for sequence_to_classify_english in items_values_female:
            # for index, sequence_to_classify_english in zip(range(1,len(items_darktetrad)+1),items_darktetrad):
            answer=classifier(sequence_to_classify_english, candidate_labels_english)
            print(answer)
            answerlist_english.append(answer)
             
        answer_english_df=pd.DataFrame([dict(zip(x['labels'],x['scores'])) for x in answerlist_english])
        
        answer_english_df.rename(columns = {"Not like me at all":1, "Not like me":2, "A little like me":3, "Moderately like me":4, "Like me":5,"Very much like me":6},inplace = True)
        
        answer_english_df.sort_index(axis=1, inplace=True)
        
        answer_english_df.insert(0, 'item_index', list(range(1,len(items_values_female)+1)))
        
        answer_english_df.insert(0, 'item', [x['sequence'] for x in answerlist_english])
        
        answer_english_df.insert(len(answer_english_df.columns), 'model', model_name)
        
        answer_english_df.insert(len(answer_english_df.columns), 'lang', "en")
        
        dflist.append(answer_english_df)
    
    
answerdf=pd.concat(dflist)

answerdf.to_csv(path+"answerdf_values_female.tsv",sep="\t",index=False)









# Gender

candidate_labels_english = ["strongly disagree","disagree","somewhat disagree","neither agree or disagree","somewhat agree","agree","strongly agree"]

items_values_gender=["A person’s gender can change over time.",
"Non-binary gender identities are valid.",
"Non-binary gender identities have always existed.",
"People who express their gender in ways that go against society’s norms are just being their true selves.",
"Gender is about how you express yourself (e.",
"Being a woman or a man has nothing to do with what genitals you have.",
"The only thing that determines whether someone truly is a woman or a man is whether they identify as a woman or a man.",
"Transgender identities are natural.",
"Transgender people were born the way they are.",
"It would be best if society stopped labeling people based on whether they are female or male.",
"There are many different gender identities people can have.",
"Biological sex is not just female or male; there are many possibilities.",
"It is possible to have more than one gender identity at the same time.",
"Not all cultures have the same gender identities.",
"Men who behave in feminine ways are looking for attention.",
"A real man needs to be masculine.",
"People of the same gender tend to be similar to each other.",
"People who have the same biological sex are mostly similar to each other.",
"Feminine people are similar to other feminine people, and masculine people are similar to other masculine people.",
"A person with a penis can only ever be a woman if they have surgery to have a vagina instead.",
"A person with a vagina can only ever be a man if they have surgery to have a penis instead.",
"Gender identity is affected by how a person is raised.",
"A person’s experiences growing up determine whether they will be feminine or masculine."]



dflist=[]

for model_name in model_names:
    
    
    classifier = pipeline("zero-shot-classification",model=model_name) 
        
    
    # now english
    if("en" in model_language[model_name]):
    
        answerlist_english=[]
        
        for sequence_to_classify_english in items_values_gender:
            # for index, sequence_to_classify_english in zip(range(1,len(items_darktetrad)+1),items_darktetrad):
            answer=classifier(sequence_to_classify_english, candidate_labels_english)
            print(answer)
            answerlist_english.append(answer)
             
        answer_english_df=pd.DataFrame([dict(zip(x['labels'],x['scores'])) for x in answerlist_english])
        
        answer_english_df.rename(columns = {"strongly disagree":1, "disagree":2, "somewhat disagree":3, "neither agree or disagree":4, "somewhat agree":5,"agree":6,"strongly agree":7},inplace = True)
        
        answer_english_df.sort_index(axis=1, inplace=True)
        
        answer_english_df.insert(0, 'item_index', list(range(1,len(items_values_gender)+1)))
        
        answer_english_df.insert(0, 'item', [x['sequence'] for x in answerlist_english])
        
        answer_english_df.insert(len(answer_english_df.columns), 'model', model_name)
        
        answer_english_df.insert(len(answer_english_df.columns), 'lang', "en")
        
        dflist.append(answer_english_df)
    
    
answerdf=pd.concat(dflist)

answerdf.to_csv(path+"answerdf_gender.tsv",sep="\t",index=False)








# Moral Foundations

# Part 1

candidate_labels_english = ["not at all relevant", "not very relevant","slightly relevant","somewhat relevant","very relevant","extremely relevant"]


items_values_mf_1=["Whether or not someone suffered emotionally","Whether or not some people were treated differently than others","Whether or not someone’s action showed love for his or her country",
"Whether or not someone showed a lack of respect for authority","Whether or not someone violated standards of purity and decency","Whether or not someone was good at math",
"Whether or not someone cared for someone weak or vulnerable","Whether or not someone acted unfairly","Whether or not someone did something to betray his or her group",
"Whether or not someone conformed to the traditions of society","Whether or not someone did something disgusting","Whether or not someone was cruel",
"Whether or not someone was denied his or her rights","Whether or not someone showed a lack of loyalty","Whether or not an action caused chaos or disorder",
"Whether or not someone acted in a way that God would approve of"]



dflist=[]

for model_name in model_names:
    
    
    classifier = pipeline("zero-shot-classification",model=model_name) 
        
    
    # now english
    if("en" in model_language[model_name]):
    
        answerlist_english=[]
        
        for sequence_to_classify_english in items_values_mf_1:
            # for index, sequence_to_classify_english in zip(range(1,len(items_darktetrad)+1),items_darktetrad):
            answer=classifier(sequence_to_classify_english, candidate_labels_english)
            print(answer)
            answerlist_english.append(answer)
             
        answer_english_df=pd.DataFrame([dict(zip(x['labels'],x['scores'])) for x in answerlist_english])
        
        answer_english_df.rename(columns = {"not at all relevant":0, "not very relevant":1, "slightly relevant":2, "somewhat relevant":3, "very relevant":4,"extremely relevant":5},inplace = True)
        
        answer_english_df.sort_index(axis=1, inplace=True)
        
        answer_english_df.insert(0, 'item_index', list(range(1,len(items_values_mf_1)+1)))
        
        answer_english_df.insert(0, 'item', [x['sequence'] for x in answerlist_english])
        
        answer_english_df.insert(len(answer_english_df.columns), 'model', model_name)
        
        answer_english_df.insert(len(answer_english_df.columns), 'lang', "en")
        
        dflist.append(answer_english_df)
    
    
answerdf=pd.concat(dflist)

answerdf.to_csv(path+"answerdf_mf_1.tsv",sep="\t",index=False)




# Part 2

candidate_labels_english = ["strongly disagree","moderately disagree","slightly disagree","slightly agree","moderately agree","strongly agree"]

items_values_mf_2=["Compassion for those who are suffering is the most crucial virtue.","When the government makes laws, the number one principle should be ensuring that everyone is treated fairly.","I am proud of my country’s history.",
"Respect for authority is something all children need to learn.","People should not do things that are disgusting, even if no one is harmed.","It is better to do good than to do bad.",
"One of the worst things a person could do is hurt a defenseless animal.","Justice is the most important requirement for a society.","People should be loyal to their family members, even when they have done something wrong.",
"Men and women each have different roles to play in society.","I would call some acts wrong on the grounds that they are unnatural.","It can never be right to kill a human being.",
"I think it’s morally wrong that rich children inherit a lot of money while poor children inherit nothing.","It is more important to be a team player than to express oneself.","If I were a soldier and disagreed with my commanding officer’s orders, I would obey anyway because that is my duty.",
"Chastity is an important and valuable virtue."]



dflist=[]

for model_name in model_names:
    
    
    classifier = pipeline("zero-shot-classification",model=model_name) 
        
    
    # now english
    if("en" in model_language[model_name]):
    
        answerlist_english=[]
        
        for sequence_to_classify_english in items_values_mf_2:
            # for index, sequence_to_classify_english in zip(range(1,len(items_darktetrad)+1),items_darktetrad):
            answer=classifier(sequence_to_classify_english, candidate_labels_english)
            print(answer)
            answerlist_english.append(answer)
             
        answer_english_df=pd.DataFrame([dict(zip(x['labels'],x['scores'])) for x in answerlist_english])
        
        answer_english_df.rename(columns = {"strongly disagree":0, "moderately disagree":1, "slightly disagree":2, "slightly agree":3, "moderately agree":4,"strongly agree":5},inplace = True)
        
        answer_english_df.sort_index(axis=1, inplace=True)
        
        answer_english_df.insert(0, 'item_index', list(range(17,17+len(items_values_mf_2))))
        
        answer_english_df.insert(0, 'item', [x['sequence'] for x in answerlist_english])
        
        answer_english_df.insert(len(answer_english_df.columns), 'model', model_name)
        
        answer_english_df.insert(len(answer_english_df.columns), 'lang', "en")
        
        dflist.append(answer_english_df)
    
    
answerdf=pd.concat(dflist)

answerdf.to_csv(path+"answerdf_mf_2.tsv",sep="\t",index=False)
