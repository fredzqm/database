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
    
    public partial class STime
    {
        public int SectID { get; set; }
        public string Classroom { get; set; }
        public byte Period { get; set; }
        public byte Weekday { get; set; }
    
        public virtual Section Section { get; set; }
    }
}
