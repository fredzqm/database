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
    
    public partial class SectionView
    {
        public int SectID { get; set; }
        public Nullable<short> Section { get; set; }
        public Nullable<int> TermID { get; set; }
        public string ProfName { get; set; }
        public byte Credit { get; set; }
        public Nullable<byte> EnrollNum { get; set; }
    }
}
