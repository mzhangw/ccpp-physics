!>\file h2ophys.f
!! This file include NRL H2O physics for stratosphere and mesosphere.

!> This module contains the CCPP-compliant H2O physics for stratosphere and mesosphere. 
      module h2ophys

      implicit none

      private

      public :: h2ophys_init, h2ophys_run, h2ophys_finalize

      contains

! \brief Brief description of the subroutine
!
!> \section arg_table_h2ophys_init Argument Table
!!
      subroutine h2ophys_init()
      end subroutine h2ophys_init

!>\defgroup GFS_h2ophys GFS h2ophys Main
!> This subroutine is NRL H2O physics for stratosphere and mesosphere.
!! \section arg_table_h2ophys_run Argument Table
!! | local_name     | standard_name                                     | long_name                                         | units   | rank | type      | kind      | intent | optional |
!! |----------------|---------------------------------------------------|---------------------------------------------------|---------|------|-----------|-----------|--------|----------|
!! | ix             | horizontal_dimension                              | horizontal dimension                              | count   |    0 | integer   |           | in     | F        |
!! | im             | horizontal_loop_extent                            | horizontal loop extent                            | count   |    0 | integer   |           | in     | F        |
!! | levs           | vertical_dimension                                | number of vertical layers                         | count   |    0 | integer   |           | in     | F        |
!! | kh2o           | vertical_dimension_of_h2o_forcing_data            | number of vertical layers in h2o forcing data     | count   |    0 | integer   |           | in     | F        |
!! | dt             | time_step_for_physics                             | physics time step                                 | s       |    0 | real      | kind_phys | in     | F        |
!! | h2o            | water_vapor_specific_humidity_updated_by_physics  | water vapor specific humidity updated by physics  | kg kg-1 |    2 | real      | kind_phys | inout  | F        |
!! | ph2o           | natural_log_of_h2o_forcing_data_pressure_levels   | natural log of h2o forcing data pressure levels   | log(Pa) |    1 | real      | kind_phys | in     | F        |
!! | prsl           | air_pressure                                      | mid-layer pressure                                | Pa      |    2 | real      | kind_phys | in     | F        |
!! | h2opltc        | h2o_forcing                                       | water forcing data                                | various |    3 | real      | kind_phys | in     | F        |
!! | h2o_coeff      | number_of_coefficients_in_h2o_forcing_data        | number of coefficients in h2o forcing data        | index   |    0 | integer   |           | in     | F        |
!! | ldiag3d        | flag_diagnostics_3D                               | flag for calculating 3-D diagnostic fields        | flag    |    0 | logical   |           | in     | F        |
!! | me             | mpi_rank                                          | rank of the current MPI task                      | index   |    0 | integer   |           | in     | F        |
!! | errmsg         | ccpp_error_message                                | error message for error handling in CCPP          | none    |    0 | character | len=*     | out    | F        |
!! | errflg         | ccpp_error_flag                                   | error flag for error handling in CCPP             | flag    |    0 | integer   |           | out    | F        |
!!
!! \section genal_h2ophys GFS H2O Physics Scheme General Algorithm
!> @{
      subroutine h2ophys_run(ix, im, levs, kh2o, dt, h2o, ph2o, prsl,   &
     &                     h2opltc, h2o_coeff, ldiag3d, me,             &
     &                     errmsg, errflg)
!
! May 2015 - Shrinivas Moorthi - Adaptation of NRL H2O physics for
!                                stratosphere and mesosphere
!
!     this code assumes that both prsl and ph2o are from bottom to top
!     as are all other variables
!
      use machine , only : kind_phys
      implicit none
!     interface variables
      integer, intent(in) :: ix, im, levs, kh2o, h2o_coeff, me
      real(kind=kind_phys), intent(in) :: dt
      real(kind=kind_phys), intent(inout) :: h2o(ix,levs)
      real(kind=kind_phys), intent(in) :: ph2o(kh2o)
      real(kind=kind_phys), intent(in) :: prsl(ix,levs)
      real(kind=kind_phys), intent(in) :: h2opltc(ix,kh2o,h2o_coeff)
      logical             , intent(in) :: ldiag3d
      !real(kind=kind_phys), intent(inout) :: h2op(ix,levs,h2o_coeff)
      character(len=*),     intent(out) :: errmsg
      integer,              intent(out) :: errflg
!     local variables
      integer k,kmax,kmin,l,i,j
      logical              flg(im)
      real(kind=kind_phys) pmax, pmin, tem, temp
      real(kind=kind_phys) wk1(im), wk2(im), wk3(im), pltc(im,h2o_coeff)
     &,                    h2oib(im)
      real, parameter :: prsmax=10000.0, pmaxl=log(prsmax)
!
!     initialize CCPP error handling variables
      errmsg = ''
      errflg = 0
!
!     write(1000+me,*)' in h2ophys ix=',ix, im, levs, kh2o, dt
      do l=1,levs
        pmin =  1.0e10
        pmax = -1.0e10
!
        do i=1,im
          wk1(i) = log(prsl(i,l))
          pmin   = min(wk1(i), pmin)
          pmax   = max(wk1(i), pmax)
          pltc(i,:) = 0.0
        enddo
        if (pmin < pmaxl) then
          kmax = 1
          kmin = 1
          do k=1,kh2o-1
            if (pmin < ph2o(k)) kmax = k
            if (pmax < ph2o(k)) kmin = k
          enddo
!
          do k=kmin,kmax
            temp = 1.0 / (ph2o(k) - ph2o(k+1))
            do i=1,im
              flg(i) = .false.
              if (wk1(i) < ph2o(k) .and. wk1(i) >= ph2o(k+1)) then
                flg(i) = .true.
                wk2(i) = (wk1(i) - ph2o(k+1)) * temp
                wk3(i) = 1.0 - wk2(i)
              endif
            enddo
            do j=1,h2o_coeff
              do i=1,im
                if (flg(i)) then
                  pltc(i,j)  = wk2(i) * h2opltc(i,k,j)
     &                       + wk3(i) * h2opltc(i,k+1,j)
                endif
              enddo
            enddo
          enddo
!
          do j=1,h2o_coeff
            do i=1,im
              if (wk1(i) < ph2o(kh2o)) then
                pltc(i,j) = h2opltc(i,kh2o,j)
              endif
              if (wk1(i) >= ph2o(1)) then
                pltc(i,j) = h2opltc(i,1,j)
              endif
            enddo
          enddo
        endif
        do i=1,im
          if (prsl(i,l) < prsmax) then
            h2oib(i)  = h2o(i,l)            ! no filling
            tem       = 1.0 / pltc(i,2)     ! 1/teff
            h2o(i,l)  = (h2oib(i) + (pltc(i,1)+pltc(i,3)*tem)*dt)
     &                 / (1.0 + tem*dt)
          endif

!           if (i == 1) write(1000+me,*)' h2oib=',h2oib(i),' pltc1=',
!    &pltc(i,1),' pltc2=', pltc(i,2),' tem=',tem ,' dt=',dt
!    &,' l=',l
        enddo
!
!       if (ldiag3d) then     !    h2o change diagnostics
!         do i=1,im
!           h2op(i,l,1) = h2op(i,l,1) + pltc(i,1)*dt
!           h2op(i,l,2) = h2op(i,l,2) + (h2oo(i,l) - h2oib(i))
!         enddo
!       endif
      enddo                   ! vertical loop
!
      return
      end subroutine h2ophys_run
!> @}

! \brief Brief description of the subroutine
!
!> \section arg_table_h2ophys_finalize Argument Table
!!
      subroutine h2ophys_finalize()
      end subroutine h2ophys_finalize

      end module h2ophys
