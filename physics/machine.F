      module machine

#if 0
!! \section arg_table_machine
!! | local_name                        | standard_name             | long_name                                             | units   | rank | type      |   kind   | intent | optional |
!! |-----------------------------------|-------------------------- |-------------------------------------------------------|---------|------|-----------|----------|--------|----------|
!! | kind_dyn                          | kind_dyn                  | definition of kind_dyn                                | none    |    0 | integer   |          | none   | F        |
!! | kind_grid                         | kind_grid                 | definition of kind_grid                               | none    |    0 | integer   |          | none   | F        |
!! | kind_phys                         | kind_phys                 | definition of kind_phys                               | none    |    0 | integer   |          | none   | F        |
!!
#endif

      implicit none
      
#ifndef SINGLE_PREC
      integer, parameter :: kind_io4  = 4, kind_io8  = 8 , kind_ior = 8 &
     &,                     kind_evod = 8, kind_dbl_prec = 8            &
#ifdef __PGI
     &,                     kind_qdt_prec = 8                           &
#else
     &,                     kind_qdt_prec = 16                          &
#endif
     &,                     kind_rad  = 8                               &
     &,                     kind_phys = 8     ,kind_taum=8              &
     &,                     kind_grid = 8                               &
     &,                     kind_REAL = 8                               &! used in cmp_comm
     &,                     kind_INTEGER = 4                             ! -,,-

#else
      integer, parameter :: kind_io4  = 4, kind_io8  = 8 , kind_ior = 8 &
     &,                     kind_evod = 4, kind_dbl_prec = 8            &
#ifdef __PGI
     &,                     kind_qdt_prec = 8                           &
#else
     &,                     kind_qdt_prec = 16                          &
#endif
     &,                     kind_rad  = 4                               &
     &,                     kind_phys = 4     ,kind_taum=4              &
     &,                     kind_grid = 4                               &
     &,                     kind_REAL = 4                               &! used in cmp_comm
     &,                     kind_INTEGER = 4                             ! -,,-

#endif

#ifdef OVERLOAD_R4
      integer, parameter :: kind_dyn  = 4 
#else
      integer, parameter :: kind_dyn  = 8
#endif

!
      real(kind=kind_evod), parameter :: mprec = 1.e-12           ! machine precision to restrict dep
      real(kind=kind_evod), parameter :: grib_undef = 9.99e20     ! grib undefine value
!
      end module machine
