function mytime2(args)
xloc=subwrd(args,1)
yloc=subwrd(args,2)
'draw string 'xloc' 'yloc' 'mytime()
return

function mytime
  'query time'
  sres = subwrd(result,3)
  i = 1
  while (substr(sres,i,1)!='Z')
    i = i + 1
  endwhile
  hour = substr(sres,1,i)
  isav = i
  i = i + 1
  while (substr(sres,i,1)>='0' & substr(sres,i,1)<='9')
    i = i + 1
  endwhile
  day = substr(sres,isav+1,i-isav-1)
  month = substr(sres,i,3)
  year = substr(sres,i+3,4)
  return (hour' 'day' 'month' 'year)

