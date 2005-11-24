!
! This module contains subroutines and variables for setting the 
! colour schemes for rendered plots
!
module colours
 implicit none
 integer, parameter :: ncolourmax = 256
 integer, parameter :: ncolourschemes = 10
 character(len=17), dimension(ncolourschemes), parameter :: schemename = &
    (/'greyscale        ', &
      'red              ', &
      'ice blue         ', &
      'rainbow          ', &
      'universe         ', &
      'shade of pale    ', &
      'red-blue-yellow  ', &
      'heat             ', &
      'blue-yellow-red  ', &
      'purple-blue-green'/)

contains

! ------------------------------------------------------------------------
!      defines colour schemes for rendering
!      ** add your own here **
! ------------------------------------------------------------------------     
subroutine colour_set(icolourscheme)
  implicit none
  integer, intent(in) :: icolourscheme
  integer :: i,icolourmin,icolmin,icolmax,ncolmax,ncolours,nset
  real :: hue,light,sat,brightness,red,green,blue
  real :: dhue,dlight,dsat,dred,dgreen,dblue
  real, dimension(7) :: lumarr,redarr,greenarr,bluearr
  logical :: rgb
      
  red = 0.0
  green = 0.0
  blue = 0.0
  rgb = .false.
  ncolours = ncolourmax
  nset = 5
!
!--set first colour index (warning: colours 1-16 have presets, so
!  overwriting these means that line graphs that use colour will come
!  out funny). Best to leave 0 and 1 alone as these are black and white.
!
  icolourmin = 2
!
!--inquire as to colour range available on current device
!  adjust ncolours if necessary
!      
  call PGQCOL(icolmin,icolmax)
  !!print*,' from device = ',icolmin,icolmax
  call PGQCIR(icolmin,icolmax)
  !!print*,' other = ',icolmin,icolmax
  if (icolourmin.lt.icolmin) icolourmin = icolmin
  ncolmax = icolmax - icolourmin
  if (ncolours.gt.ncolmax) then  
     ncolours = ncolmax
     print*,'Warning: Device allows only ',ncolours+1,' colours'
  endif
  !
  !--set this as the range of colour indices to use
  !
  call PGSCIR(icolourmin,icolourmin+ncolours)  

!
!--starting values
!      
  select case(icolourscheme)
  case(2)  
!    red
     rgb = .false.
     hue=100
     light=0.0
     sat=1.0      
     dlight = 1.0/FLOAT(ncolours)
     dsat = 0.0
     dhue = 80.0/FLOAT(ncolours)         
  case(3)        ! blue
!    ice blue
     rgb = .false.
     hue=330
     light=0.0
     sat=1.0
     dlight = 1.0/FLOAT(ncolours)
     dsat = 0.0
     dhue = 40.0/FLOAT(ncolours)
  case(4) 
!    rainbow
     rgb = .false.         
     hue=100
     light=0.5
     sat=1.0
     dlight = 0.0        !/FLOAT(ncolours)
     dsat = 0.0
     dhue = 320.0/FLOAT(ncolours)
  case(5)        ! green
!    universe
     rgb = .true.         
     red=0.
     green=0.
     blue=1./6.
     dred =1.0/FLOAT(ncolours)
     dgreen = 1.0/FLOAT(ncolours)
     dblue = (1./6.)/FLOAT(ncolours)       
  case(6)        ! rgb attempts
!    shade of pale
     rgb = .true.
     red = 0.09
     green = -1.
     blue = -2.
     dred = 1./FLOAT(ncolours)
     dblue = 1./FLOAT(ncolours)
     dgreen = 1./FLOAT(ncolours)         
!  case default
!    default is greyscale
!!     return
  end select
!
!--set colour indexes from icolourmin-> icolourmin+ncolours
!  increment values in steps
!
  if (icolourscheme .le. 6) then
     do i=icolourmin,icolourmin+ncolours
        if (rgb) then
           red = red + dred
           blue = blue + dblue
           green = green + dgreen
           red = min(red,1.0)
           blue = min(blue,1.0)
           green = min(green,1.0)
           red = max(red,0.)
           blue = max(blue,0.)
           green = max(green,0.)
           call PGSCR(i,red,green,blue)
        else   
           hue = hue + dhue
           sat = sat + dsat
           light = light + dlight
           call PGSHLS(i,hue,light,sat)
        endif
     enddo
  else
     brightness = 0.5
     select case(icolourscheme)
     case(6)
     nset = 5
     lumarr(1:nset) = (/0.0,0.25,0.5,0.75,1.0/)
     redarr(1:nset) = (/0.0,1.0,1.0,1.0,0.0/)
     bluearr(1:nset) = (/1.0,1.0,0.0,0.0,0.0/)
     greenarr(1:nset) = (/0.0,0.0,0.0,1.0,1.0/)
     case(7)
     nset = 7
     !--red-blue-yellow
     lumarr(1:nset) =   (/0.0,0.2,0.35,0.4, 0.7, 0.9,1.0/)
     redarr(1:nset) =   (/0.0,0.9,0.01,0.25,0.5,0.75,1.0/)
     bluearr(1:nset) =  (/0.0,0.2,0.48,0.50,1.0,0.05,1.0/)
     greenarr(1:nset) = (/0.0,0.1,0.24,0.25,0.5,0.75,1.0/)
     case(8)
     !--heat
     nset = 5
     lumarr(1:nset) =  (/0.,0.25,0.5,0.75,1.0/)
     redarr(1:nset) =  (/0.0,0.0,0.0,1.0,1.0/)
     bluearr(1:nset) = (/1.0,1.0,0.0,0.0,0.0/)
     greenarr(1:nset)= (/0.0,1.0,1.0,1.0,0.0/)
     case(9)
     !--blue-yellow-red
     nset = 6
     lumarr(1:nset) =  (/0.0,0.2,0.4,0.6,0.8,1.0/)
     redarr(1:nset) =  (/0.0,0.0,0.5,1.0,1.0,0.5/)
     bluearr(1:nset) = (/1.0,1.0,0.5,0.0,0.0,0.0/)
     greenarr(1:nset)= (/0.0,1.0,0.5,1.0,0.0,0.0/)
     case(10)
     !--purple-blue-green
     nset = 6
     lumarr(1:nset) =  (/0.0,0.1,0.2,0.5,0.8,1.0/)
     redarr(1:nset) =  (/0.0,0.1,0.5,0.02,0.0,0.0/)
     bluearr(1:nset) = (/0.0,0.2,0.5,0.98,0.0,0.0/)
     greenarr(1:nset)= (/0.0,0.0,0.0,0.0,0.62,0.98/)
     end select

     call PGCTAB(lumarr(1:nset),redarr(1:nset),greenarr(1:nset),bluearr(1:nset), &
                 nset,1.0,brightness)

  endif  
!
!--always set the minimum colour to the background
!
  call PGQCR(0,red,green,blue)
  call PGSCR(icolourmin,red,green,blue)
  
  print*,'using colour scheme ',trim(schemename(icolourscheme))
  return
  
end subroutine colour_set

!------------------------------------------------
! demonstration plot of all the colour schemes
!------------------------------------------------
subroutine colour_demo
  implicit none
  integer :: i,j,nc
  !
  !--npixx should be >= ncolours in setcolours.f
  !      
  integer, parameter :: npixx = ncolourmax
  integer, parameter :: npixy = npixx/10
  real, dimension(npixx,npixy) :: sample
  real :: xmin,xmax,ymin,ymax,dx,dy,trans(6)
  character(len=10) :: string

  call pgbegin(0,'/xw',1,ncolourschemes)
!!  call pgpaper(6.0,8.0) !!!0.25/sqrt(2.))

  xmin = 0.0
  xmax = 1.0
  ymin = 0.0
  ymax = 0.1
  dx = (xmax-xmin)/float(npixx)
  dy = (ymax-ymin)/float(npixy)
  trans(1) = xmin - 0.5*dx
  trans(2) = dx
  trans(3) = 0.0
  trans(4) = ymin - 0.5*dy
  trans(5) = 0.0
  trans(6) = dy

  do j=1,npixy
     do i=1,npixx
        sample(i,j) = (i-1)*dx
     enddo
  enddo
  call pgsch(2.0)
  call pgenv(xmin,xmax,ymin,ymax,0,-1)
  call pgsch(1.0)
  call pggray(sample,npixx,npixy,1,npixx,1,npixy, &
              minval(sample),maxval(sample),trans)
  call pgnumb(1,0,0,string,nc)
  call pgsch(7.0)
  call pgmtxt('t',0.5,0.5,0.5,string(1:nc)//': '//trim(schemename(1)))

  do i=2,ncolourschemes
     call pgsch(2.0)      
     call pgenv(xmin,xmax,ymin,ymax,0,-1) 
     call pgsch(7.0)
     call pgnumb(i,0,0,string,nc)
     call pgmtxt('t',0.5,0.5,0.5,string(1:nc)//': '//trim(schemename(i)))     
     call colour_set(i)
     call pgimag(sample,npixx,npixy,1,npixx,1,npixy, &
                 minval(sample),maxval(sample),trans)
  enddo

  call pgsch(1.0)
  call pgend 

end subroutine colour_demo

end module colours
