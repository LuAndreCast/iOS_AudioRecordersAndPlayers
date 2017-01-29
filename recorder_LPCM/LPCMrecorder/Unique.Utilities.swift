

import Foundation

@objc class MyFileManager:NSObject
{
     private let unique_debug = false
     private var _temporyDirectory:String = ""

    //MARK: - Properties
    var directory:String {
        return _temporyDirectory
    }

    //MARK: - Init
    override init() {
        super.init()

        _temporyDirectory = NSTemporaryDirectory()
    }//eom

    func createHomeDirFileUniqueWithName(_ myFileName:String, andExtension fileExtension:String)->URL
    {
        //filename
        let time:Date = Date.init()
        let dateformatter:DateFormatter = DateFormatter()
        dateformatter .dateFormat = "ddMMyyyy-hh-mm-ss-a"
        let tempDate:String = dateformatter .string(from: time)
        let tempFileName = "\(myFileName)-\(tempDate).\(fileExtension)"

        //directory
        var documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        documentsDirectory.appendPathComponent(tempFileName)

        if unique_debug {  print("\(documentsDirectory)") }

        return documentsDirectory
    }//eom

    //MARK: - Names
    func createGlobalUniqueFileName(_ myFileName:String)->String
    {
        let guid = ProcessInfo.processInfo.globallyUniqueString
        let uniqueFileName = ("\(myFileName)_\(guid)")
        
        if unique_debug {  print("\(uniqueFileName)") }
        
        return uniqueFileName
    }//eom
    
    func createUniqueNameWithFilename(_ myFileName:String, andExtension fileExtension:String)->String
    {
        //filename
        let time:Date = Date.init()
        let dateformatter:DateFormatter = DateFormatter()
        dateformatter .dateFormat = "ddMMyyyy-hh-mm-ss-a"
        let currentDateString = dateformatter .string(from: time)
        
        let finalName = myFileName + currentDateString + "." + fileExtension

        if unique_debug {  print("\(finalName)") }

        return finalName
    }//eom

    //MARK: - Paths
    func createTempFilePathWithUniqueName(_ myFileName:String, andExtension fileExtension:String)->String
    {
        let tempFileName = self.createUniqueNameWithFilename(myFileName, andExtension: fileExtension)

        let tempFile = _temporyDirectory + tempFileName

        if unique_debug {  print("\(tempFile)") }

        return tempFile
    }//eom

    //MARK: - Helpers
    func enumerateDirectory(directory:String)
    {
        do
        {
            let filesInDir:[String] = try FileManager.default.contentsOfDirectory(atPath: directory)
            for currFile in filesInDir {
                print(currFile)
            }//eofl
        }
        catch let error
        {
            print("error: \(error.localizedDescription)")
        }
    }//eom

    func doesFileExistInDirectory(filename:String) -> Bool {
        do
        {
            let filesInDir:[String] = try FileManager.default.contentsOfDirectory(atPath: _temporyDirectory)
            for currFile in filesInDir
            {
                print(currFile)
                if currFile == filename {
                    return true
                }
            }//eofl
        }
        catch let error
        {
            print("error: \(error.localizedDescription)")
        }

        return false
    }//eom
 
}//eoc


