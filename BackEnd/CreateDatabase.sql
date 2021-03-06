USE master
GO

IF DB_ID ('APlanner') IS NOT NULL
	Drop database [APlanner];
GO

CREATE DATABASE APlanner;
GO

USE APlanner
GO

Create Table People (
	UserID varchar(9) unique,
	UserName varchar(12) unique,
	FName varchar(30) not null,
	LName varchar(30) not null,
	type char(1),
	Password char(20) not null,

	Primary key(UserID),
	Constraint PeopleType Check ( type = 'S' or type = 'P' )
)
Go

CREATE INDEX People_UserName
    ON People(UserName);
Go

Create Table Friend (
	Requester varchar(9) not null,
	Accepter varchar(9) not null,
	time date,
	Primary key(Requester, Accepter),
	Foreign key(Requester) references People(UserID)
		on update cascade on delete cascade,
	Foreign key(Accepter) references People(UserID)
 		on update no action on delete no action,
	Constraint Friend_Different check (Requester <> Accepter),
	Constraint Friend_Exist Check ( Requester <> null or  Accepter <> null )
)
Go

Create Table FriendRequest (
	Requester varchar(9) not null,
	Accepter varchar(9) not null,
	time date,
	
	Primary key(Requester, Accepter),
	Foreign key(Requester) references People(UserID),
	Foreign key(Accepter) references People(UserID)
);
Go

Create Table Message (
	MessID int IDENTITY (1,1),
	Sender varchar(9),
	Receiver varchar(9),
	Content text not null,
	time datetime,

	Primary key(MessID),
	Foreign key(Sender) references People(UserID)
		on update no action on delete set null,
	Foreign key(Receiver) references People(UserID),
		--- on update no action on delete set null
	Constraint MessOwner Check ( Sender <> null or  Receiver <> null )
);
Go

Create Table Department(
	DepartID varchar(5) primary key,
	DepartNAME varchar(50) not null
);
Go


Create Table Professor (
	PUserID varchar(9) primary key,
	DepartID varchar(5) not null,
	Office varchar(6) not null,
	Foreign key(PUserID) references People(UserID)
		on update cascade on delete cascade,
	Foreign key(DepartID) references Department(DepartID)
		-- reject all changes
)
Go

Create Table Student (
	SUserID varchar(9) primary key,
	Major varchar(12) DEFAULT 'Undeclared',
	Year smallint not null,
	
	Foreign key(SUserID) references People(UserID)
		on update cascade on delete cascade
)
Go

Create Table Term (
	TermID int primary key,
	Start_date date not null,
	End_date date not null
)
Go

Create Table SPlan (
	PID int primary key IDENTITY (1,1),
	SUserID varchar(9) not null,
	TermID int,
	Priority tinyint,
	Probability float,
	
	Foreign key(SUserID) references Student(SUserID)
		on update cascade on delete cascade,
	Foreign key(TermID) references Term(TermID)
		--- reject all changes
)
Go

CREATE INDEX SPlan_SUserIndex
    ON SPlan(SUserID);
go

CREATE INDEX SPlan_TermIDIndex
    ON SPlan(TermID);

Create Table Course (
	CourseID smallint identity(1, 1),
	CourseDP varchar(5) not null,
	CourseName varchar(50),
	CourseNum smallint,
	Description text default '',
	Credit tinyint,

	Primary key(CourseID),
	Foreign key(CourseDP) references Department(DepartID)
		on update no action on delete no action -- reject changes
)
Go

CREATE INDEX Course_DepartIndex
    ON Course(CourseDP);
go

CREATE INDEX Course_Index
    ON Course(CourseDP, CourseNum);
go

Create Table Contain (
	CourseID smallint not null,
	PID int not null,
	
	Primary key(CourseID, PID),
	Foreign key(CourseID) references Course(CourseID)
		on update cascade on delete cascade,  -- create a trigger
 	Foreign key(PID) references SPlan(PID)
		on update cascade on delete cascade
)
Go

CREATE INDEX Contain_CourseIndex
    ON Contain(CourseID);
go

Create Table Prerequisite (
	Prerequisite smallint not null,
	Requisite smallint not null,

	Primary key(Prerequisite, Requisite),
	Foreign key(Prerequisite) references Course(CourseID),
	    --- use trigger to handle it
	Foreign key(Requisite) references Course(CourseID)
		--- on update cascade on delete set null,
)
Go

Create Table Schedule (
	ScheID int IDENTITY (1,1),
	PID int,
	Probability float,
	Priority tinyint,
	PublicOrPrivate bit not null,
	
	Primary key(ScheID),
	Foreign key(PID) references SPlan(PID)
		on update cascade on delete set null
)
Go

CREATE INDEX Schedule_PlanIndex
    ON Schedule(PID);
go

Create Table Section (
	SectID int IDENTITY (1,1),
	TermID int,
	CourseID smallint not null,
	SectNum tinyint not null,
	PUserID varchar(9) default null,
	EnrollNum tinyint default 0,
	Capacity int default 0,

	Primary key(SectID),
	Foreign key(TermID) references Term(TermID),
		-- rejcts all changes
	Foreign key(CourseID) references Course(CourseID)
		on update no action on delete no action, --- on update cascade on delete cascade
	Foreign key(PUserID) references Professor(PUserID)
		on update cascade on delete no action,  --- avoid loss of information
	CONSTRAINT Section_Unique UNIQUE(TermID, CourseID, SectNum) ,
	Constraint EnrollNum_Not_Neg Check ( EnrollNum >= 0 )
)
Go

CREATE INDEX Section_TermIndex
    ON Section(TermID);
go

CREATE INDEX Section_CourseIndex
    ON Section(CourseID);
go

CREATE INDEX Section_ProfIndex
    ON Section(PUserID);
go

CREATE INDEX Section_Index
    ON Section(TermID, CourseID, SectNum);
go

Create Table Has (
	SectID int not null,
	ScheID int not null,

	Primary key(ScheID, SectID),
	Foreign key(SectID) references Section(SectID),
	Foreign key(ScheID) references Schedule(ScheID)
		on update cascade on delete cascade
)
Go

Create Table Enroll (
	SectID int not null,
	SUserID varchar(9) not null,
	Time datetime not null,
	Rating tinyint default null,

	Primary key(SectID, SUserID),
	Foreign key(SUserID) references Student(SUserID),
	Foreign key(SectID) references Section(SectID)
		on update cascade on delete cascade,
	Constraint RatingRange Check ( Rating >= 0 and Rating <= 10)
)
Go


Create Table WaitList (
	SectID int not null,
	SUserID varchar(9) not null,
	Time datetime not null,

	Primary key(SectID, SUserID),
	Foreign key(SUserID) references Student(SUserID)
		on update cascade on delete cascade,
	Foreign key(SectID) references Section(SectID)
		on update no action on delete no action, -- on update cascade on delete cascade
)

Go

Create Table STime (
	SectID int not null,
	Classroom varchar(7) default 'TBA',
	Period tinyint not null,
	Weekday tinyint not null,

	Primary key(Weekday, Period, Classroom, SectID),
	Foreign key(SectID) references Section(SectID)
		on update cascade on delete cascade,
	Constraint Proper_Period Check (
		 Period >= 1 and Period <= 10 and Weekday >= 1 and Weekday <=5
	)
);
Go

CREATE INDEX STime_SectIndex
    ON STime(SectID);
Go

CREATE INDEX STime_Classroom
    ON STime(Classroom);
go

--- Go  a stored procedure for setting permissions
Create proc ProvideOwnerPermit
	@user varchar(20)
As
begin
	--- set authority
	EXECUTE( 'CREATE USER ['+@user+'] FOR LOGIN ['+@user+'] WITH DEFAULT_SCHEMA=[dbo] ' );
	EXECUTE( 'ALTER AUTHORIZATION ON SCHEMA::[db_owner] TO ['+@user+'] ' );
	EXECUTE( 'ALTER ROLE [db_owner] ADD MEMBER ['+@user+'] ' );

	--- set permissions
	EXECUTE( 'GRANT ALTER TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY APPLICATION ROLE TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY ASSEMBLY TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY ASYMMETRIC KEY TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY CERTIFICATE TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY CONTRACT TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY DATABASE AUDIT TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY DATABASE DDL TRIGGER TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY DATABASE EVENT NOTIFICATION TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY DATASPACE TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY FULLTEXT CATALOG TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY MESSAGE TYPE TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY REMOTE SERVICE BINDING TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY ROLE TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY ROUTE TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY SCHEMA TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY SERVICE TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY SYMMETRIC KEY TO ['+@user+']' );
	EXECUTE( 'GRANT ALTER ANY USER TO ['+@user+']' );
	EXECUTE( 'GRANT AUTHENTICATE TO ['+@user+']' );
	EXECUTE( 'GRANT BACKUP DATABASE TO ['+@user+']' );
	EXECUTE( 'GRANT BACKUP LOG TO ['+@user+']' );
	EXECUTE( 'GRANT CHECKPOINT TO ['+@user+']' );
	EXECUTE( 'GRANT CONNECT TO ['+@user+']' );
	EXECUTE( 'GRANT CONNECT REPLICATION TO ['+@user+']' );
	EXECUTE( 'GRANT CONTROL TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE AGGREGATE TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE ASSEMBLY TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE ASYMMETRIC KEY TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE CERTIFICATE TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE CONTRACT TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE DATABASE DDL EVENT NOTIFICATION TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE DEFAULT TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE FULLTEXT CATALOG TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE FUNCTION TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE MESSAGE TYPE TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE PROCEDURE TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE QUEUE TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE REMOTE SERVICE BINDING TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE ROLE TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE ROUTE TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE RULE TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE SCHEMA TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE SERVICE TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE SYMMETRIC KEY TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE SYNONYM TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE TABLE TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE TYPE TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE VIEW TO ['+@user+']' );
	EXECUTE( 'GRANT CREATE XML SCHEMA COLLECTION TO ['+@user+']' );
	EXECUTE( 'GRANT DELETE TO ['+@user+']' );
	EXECUTE( 'GRANT EXECUTE TO ['+@user+']' );
	EXECUTE( 'GRANT INSERT TO ['+@user+']' );
	EXECUTE( 'GRANT REFERENCES TO ['+@user+']' );
	EXECUTE( 'GRANT SELECT TO ['+@user+']' );
	EXECUTE( 'GRANT SHOWPLAN TO ['+@user+']' );
	EXECUTE( 'GRANT SUBSCRIBE QUERY NOTIFICATIONS TO ['+@user+']' );
	EXECUTE( 'GRANT TAKE OWNERSHIP TO ['+@user+']' );
	EXECUTE( 'GRANT UPDATE TO ['+@user+']' );
	EXECUTE( 'GRANT VIEW DATABASE STATE TO ['+@user+']' );
	EXECUTE( 'GRANT VIEW DEFINITION TO ['+@user+']' );
end
Go


USE [APlanner]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_owner] TO [dbo]
GO


if not Exists ( select * from sys.databases where name = 'APlanner' and suser_sname(owner_sid) = 'zhangq2')
begin
	Exec ProvideOwnerPermit 'zhangq2';	---- this table is created by dingy2, add zhangq2 as woner
end
Go

if not Exists ( select * from sys.databases where name = 'APlanner' and suser_sname(owner_sid) = 'dingy2')
begin
	Exec ProvideOwnerPermit 'dingy2';	---- this table is created by dingy2, add zhangq2 as woner
end
Go
