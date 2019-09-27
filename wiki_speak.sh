#! /bin/bash


#UPI:ywu660  ID NUMBER:827481772


#variables
DIR="$HOME/creationHistory"
AUDIO="$DIR/audiofiles"
VIDEO="$DIR/videofiles"
TEXT="$DIR/text"
CREATION="$DIR/creation"
list=$TEXT/CreationList.txt 


#functions 

printMainmenum(){   #this function will print the main menue
  echo -n "
Please select from one of the following options:

     (l)ist existing creations
     (p)lay an existing creation
     (d)elete an existing creation
     (c)reate a new creation
     (q)uit authoring tool

Enter a selection [l/p/d/c/q]:"


}


makeDirectory(){
# this function will creat the directory if it's not exist

        if [ ! -d $DIR ]
        then  
             
             mkdir -p $DIR
             mkdir -p $AUDIO
             mkdir -p $VIDEO
             mkdir -p $TEXT
             mkdir -p $CREATION
        fi  


}

listElements(){
            
    #list=$DIR/CreationList.txt 

    if [ ! -e $list ]
    then 
        touch $list
    fi
       ls $CREATION > $list
    if [ -s $list ]
    then
         #ls $CREATION > $list
         sort -o $list $list
         sed -i 's/\.mkv$//' $list
         echo -e "\nThe creation list:"
         cat -n $list
    else
         echo "There is no creation yet."
    fi

   echo -e "\n"
   read -n 1 -s -r -p "Press any key to continue"
   echo -e "\n"
   
}



#main function
  echo -n "
==============================================================
Welcome to the Wiki-Speak Authoring Tool
=============================================================="    
printMainmenum
makeDirectory

read ACTION

while [ "$ACTION" != "q" ]
     do
        
    if [ "$ACTION" == "l" ]
    then

       listElements    
    elif [ "$ACTION" == "p" ]
    then
           
           listElements
           if [ -s $list ]
           then
              
               read -p "Please enter the creation you want to play:" play
               while [ ! -e $CREATION/"$play".mkv ]
               do
                  read -p "The file is not exit.Please try again and enter the file name list above:" play
               done

               ffplay -autoexit $CREATION/"$play".mkv &> /dev/null

           else
               echo "Please enter c to start creation first before delete."
           fi
           
    elif [ "$ACTION" == "d" ]
    then
         
        listElements

        if [ -s $list ]
        then
                read -p "Please specify the creation you want to delete:" delete
                
                
                while [ ! -e $CREATION/"$delete".mkv ]
                do 
                   read -p "The file is not exist.Please enter the file name list above:" delete
                done

                echo "Are you sure you want to delete $delete"|festival --tts &> /dev/null
                rm -i $CREATION/"$delete".mkv 
                
        else
                echo "Please enter c to start creation first before delete."
        fi
          
      
    elif [ "$ACTION" == "c" ]
    then
        
        #read the variable from user
        read -p "please enter the word you want to search: " var
        search=`wikit $var`
        
        #if the variable is inavlid keep asking user to add new variable
        while [ "$search" == "$var not found :^(" ]
             do
               read -p "Sorry, you find nothing in wikipedia, please enter a new word: " var
               search=`wikit $var`
             done
       

       history=$TEXT/history.txt
       touch $history

       #display the searching variable on screen with the sentences number
       echo $search > $history
       sed -i 's/[.!?]  */&\n/g' $history
       cat -n $history
       
       total=`wc -l < $history`
       echo -e "\nPlease enter the number between 1 and $total."
       read -p "Please enter the number of sentences :" num 
       
       
       while [[ $num -gt $total || $num -le 0 ]]
       do
           echo -e "\nPlease enter the number between 1 and $total."
           read -p "Please enter the number of sentences :" num 
       done

       num="$num"p

       #read the text file  
       sed -n 1,$num $history|festival --tts &> /dev/null

       #start creat audio
       read -p "please enter the name for your creation:" name
       
         while [ -e $AUDIO/"$name".wav ]
       do 
            read -p "The file is already exit.Do you want to (o)override or (r)rename:" decision
            if [ "$decision" == "o" ]
            then 
               echo "Override the file."
               rm -f $AUDIO/"$name".wav
               rm -f $VIDEO/"$name".mp4
               rm -f $CREATION/"$name".mkv
            else
                 read -p "Please enter a NEW name:" name
            fi  

       done 

       #create the audio file      
       sed -n 1,$num $history|text2wave -o $AUDIO/"$name".wav &> /dev/null
 
       if [ $? -eq 0 ]
         then
            echo -e "\nCongratulation!! audio file is creating successful!!!"
         else
            echo "The creation of audio file failed."
         fi

       #create the video file
        ffmpeg -f lavfi -i color=c=blue:s=1600x900:d=0.5 -vf "drawtext=fontfile=./myfont.ttf:fontsize=30: \
 fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2:text='$var'" $VIDEO/"$name".mp4 &> /dev/null

      if [ $? -eq 0 ]
      then
          
          echo "Congratulation!! Creat the video successful."
      else
           echo "The creation of video file failed."
      fi

       #combine video and audio together
        ffmpeg -i $VIDEO/"$name".mp4 -i $AUDIO/"$name".wav -c copy $CREATION/"$name".mkv &> /dev/null
        rm -f $VIDEO/video.mp4
      if [ $? -eq 0 ]
         then
               echo "Congratulation!! You finishing creation"
          else
          
               echo "Sorry, the creation failed."
      fi
          

fi


printMainmenum
read ACTION
	
done









