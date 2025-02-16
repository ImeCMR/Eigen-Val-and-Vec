 program diagonal
 implicit none
!
! Defining variables
!
 integer,parameter:: n=3
 integer:: i,j
 double precision:: a(n,n),x(n,n),b(n,n),abserr=1.0e-9
!
! Read the input file and create the output file
!
 open(unit=10, file='diagonal.dat',status='old')
 open(unit=20, file='diagonal.out',status='unknown')
!
 write(20,*) '================Matrix A=================='
 !
 ! Read statements
 !
 do i = 1,n
   read(10,*) (a(i,j),j=1,n)
   !
   ! write statement
   !
   write(20,'(3f10.5)') (a(i,j), j=1,n)
   !
   ! Assigning values in a(i,j) to b(i,j)
   !
   do j = 1,n
     b(i,j) = a(i,j)
   end do
 end do
!
! Call the subroutine
!
 call Jacobi(a,x,abserr,n)
!
 write(20,*) '================Eigen values==========='
 !
 ! Read statements
 !
 do i = 1,n
   write(20,'(3f12.6)') (a(i,j), j=1,n)
 end do
 write(20,*) '--------------Eigen vectors----------'
 do i = 1,n
   write(20,'(3f12.6)') (x(i,j), j = 1,n)
 end do
 end program diagonal
!
! ***************************************************************************
!
subroutine Jacobi(a,x,abserr,n)
!===========================================================
! Evaluate eigenvalues and eigenvectors
! of a real symmetric matrix a(n,n): a*x = lambda*x
! method: Jacoby method for symmetric matrices
! Alex G. (December 2009)
!-----------------------------------------------------------
! input ...
! a(n,n) - array of coefficients for matrix A
! n      - number of equations
! abserr - abs tolerance [sum of (off-diagonal elements)^2]
! output ...
! a(i,i) - eigenvalues
! x(i,j) - eigenvectors
! comments ...
!===========================================================
implicit none
integer:: i, j, k, n
double precision:: a(n,n),x(n,n)
double precision:: abserr, b2, bar
double precision:: beta, coeff, c, s, cs, sc

! initialize x(i,j)=0, x(i,i)=1
! *** the array operation x=0.0 is specific for Fortran 90/95
x = 0.0
do i=1,n
  x(i,i) = 1.0
end do

! find the sum of all off-diagonal elements (squared)
b2 = 0.0
do i=1,n
  do j=1,n
    if (i.ne.j) b2 = b2 + a(i,j)**2
  end do
end do

if (b2 <= abserr) return

! average for off-diagonal elements /2
bar = 0.5*b2/float(n*n)

do while (b2.gt.abserr)
  do i=1,n-1
    do j=i+1,n
      if (a(j,i)**2 <= bar) cycle  ! do not touch small elements
      b2 = b2 - 2.0*a(j,i)**2
      bar = 0.5*b2/float(n*n)
! calculate coefficient c and s for Givens matrix
      beta = (a(j,j)-a(i,i))/(2.0*a(j,i))
      coeff = 0.5*beta/sqrt(1.0+beta**2)
      s = sqrt(max(0.5+coeff,0.0))
      c = sqrt(max(0.5-coeff,0.0))
! recalculate rows i and j
      do k=1,n
        cs =  c*a(i,k)+s*a(j,k)
        sc = -s*a(i,k)+c*a(j,k)
        a(i,k) = cs
        a(j,k) = sc
      end do
! new matrix a_{k+1} from a_{k}, and eigenvectors
      do k=1,n
        cs =  c*a(k,i)+s*a(k,j)
        sc = -s*a(k,i)+c*a(k,j)
        a(k,i) = cs
        a(k,j) = sc
        cs =  c*x(k,i)+s*x(k,j)
        sc = -s*x(k,i)+c*x(k,j)
        x(k,i) = cs
        x(k,j) = sc
      end do
    end do
  end do
end do
return
end

