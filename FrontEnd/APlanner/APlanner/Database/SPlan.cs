//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace APlanner.Database
{
    using System;
    using System.Collections.Generic;
    
    public partial class SPlan
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public SPlan()
        {
            this.Schedules = new HashSet<Schedule>();
            this.Courses = new HashSet<Course>();
        }
    
        public int PID { get; set; }
        public string SUserID { get; set; }
        public int TermID { get; set; }
        public Nullable<byte> Priority { get; set; }
        public Nullable<double> Probability { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Schedule> Schedules { get; set; }
        public virtual Student Student { get; set; }
        public virtual Term Term { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Course> Courses { get; set; }
    }
}
